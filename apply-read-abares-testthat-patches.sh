#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Apply testthat-only mocking patches to read.abares (rOpenSci-review)
# - Adds internal shim .perform_request <- httr2::req_perform
# - Routes .retry_download() (and any remaining direct req_perform calls)
#   through .perform_request()
# - Adds offline tests that mock only package internals
# - Commits all changes on a new branch
#
# Usage:
#   chmod +x apply-read-abares-testthat-patches.sh
#   ./apply-read-abares-testthat-patches.sh
#
# Optional env:
#   RUN_TESTS=1   # run tests & print coverage after patching (requires covr)
# ------------------------------------------------------------

REPO_ROOT="${REPO_ROOT:-$(pwd)}"
PKG_NAME="read.abares"
TARGET_BRANCH="${TARGET_BRANCH:-rOpenSci-review}"
WORK_BRANCH="${WORK_BRANCH:-testthat-mocking-shim}"
R_DIR="${REPO_ROOT}/R"
TEST_DIR="${REPO_ROOT}/tests/testthat"
WORKFLOW="${REPO_ROOT}/.github/workflows/test-coverage.yaml"

echo ">> Repo root: ${REPO_ROOT}"

if [ ! -d "${R_DIR}" ]; then
  echo "!! Could not find R/ directory under ${REPO_ROOT}. Are you in the package root?"
  exit 1
fi

# Ensure we're in a git repo
if ! git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "!! ${REPO_ROOT} is not a git repository."
  exit 1
fi

cd "${REPO_ROOT}"

# Fetch and checkout the target branch
echo ">> Checking out target branch: ${TARGET_BRANCH}"
git fetch --all -q || true
git checkout "${TARGET_BRANCH}"

# Create a working branch
if git rev-parse --verify "${WORK_BRANCH}" >/dev/null 2>&1; then
  echo ">> Branch ${WORK_BRANCH} already exists. Checking it out."
  git checkout "${WORK_BRANCH}"
else
  echo ">> Creating branch: ${WORK_BRANCH}"
  git checkout -b "${WORK_BRANCH}"
fi

# ------------------------------------------------------------------
# 1) Add internal shim: .perform_request <- httr2::req_perform
# ------------------------------------------------------------------
HELPERS_FILE="${R_DIR}/http-helpers.R"
if [ -f "${HELPERS_FILE}" ]; then
  echo ">> Updating ${HELPERS_FILE} (ensuring .perform_request shim exists)"
  if ! grep -q "^[[:space:]]*\\.perform_request[[:space:]]*<-" "${HELPERS_FILE}"; then
    cat >>"${HELPERS_FILE}" <<'EOF'

#' Internal HTTP performer (shim for httr2::req_perform)
#'
#' All network I/O flows through this binding so tests can safely mock it.
#' @keywords internal
#' @noRd
.perform_request <- httr2::req_perform
EOF
  fi
else
  echo ">> Creating ${HELPERS_FILE} with .perform_request shim"
  mkdir -p "${R_DIR}"
  cat >"${HELPERS_FILE}" <<'EOF'
#' Internal HTTP performer (shim for httr2::req_perform)
#'
#' All network I/O flows through this binding so tests can safely mock it.
#' @keywords internal
#' @noRd
.perform_request <- httr2::req_perform
EOF
fi

# ------------------------------------------------------------------
# 2) Update .retry_download() (and any remaining direct calls) to use shim
#    - Prefer to update only the file that defines .retry_download()
#      but falling back to all R/*.R if needed is acceptable (safer seam).
# ------------------------------------------------------------------
echo ">> Locating the file that defines .retry_download()"
RETRY_FILE="$(grep -R --include='*.R' -n '^[[:space:]]*\.retry_download[[:space:]]*<-[[:space:]]*function' R | cut -d: -f1 | head -n1 || true)"

if [ -n "${RETRY_FILE}" ] && [ -f "${RETRY_FILE}" ]; then
  echo ">> Patching ${RETRY_FILE} to use .perform_request()"
  # Replace direct calls in that file
  sed -i.bak 's/httr2::req_perform[[:space:]]*(/.perform_request(/g' "${RETRY_FILE}" || true
  rm -f "${RETRY_FILE}.bak"
else
  echo "!! Could not find .retry_download() definition. Updating all R/*.R occurrences of httr2::req_perform to .perform_request"
  sed -i.bak 's/httr2::req_perform[[:space:]]*(/.perform_request(/g' R/*.R || true
  rm -f R/*.R.bak 2>/dev/null || true
fi

# ------------------------------------------------------------------
# 3) Add testthat-only mocking tests & helpers (offline)
# ------------------------------------------------------------------
echo ">> Adding test helpers and tests (testthat-only mocking)"
mkdir -p "${TEST_DIR}"

# helper-mocks.R : factories for synthetic httr2 responses
cat >"${TEST_DIR}/helper-mocks.R" <<'EOF'
# Tiny helpers to create synthetic httr2 responses for offline tests.
# See: https://httr2.r-lib.org/reference/response.html
mk_resp_json <- function(x,
                         status = 200,
                         url = "https://example.test/endpoint",
                         method = "GET") {
  httr2::response_json(
    status_code = status,
    url    = url,
    method = method,
    body   = x
  )
}

mk_resp_text <- function(text,
                         status = 200,
                         url = "https://example.test/file.csv",
                         method = "GET",
                         content_type = "text/plain; charset=utf-8") {
  httr2::response(
    status_code = status,
    url     = url,
    method  = method,
    headers = list(`Content-Type` = content_type),
    body    = charToRaw(enc2utf8(text))
  )
}

mk_resp_error <- function(status = 404,
                          url = "https://example.test/missing",
                          method = "GET") {
  httr2::response(
    status_code = status,
    url    = url,
    method = method
  )
}
EOF

# test-get_aagis_regions.R
cat >"${TEST_DIR}/test-get_aagis_regions.R" <<'EOF'
test_that("get_aagis_regions() returns an sf with expected fields", {
  # Minimal GeoJSON to keep tests tiny and offline
  gj <- '{"type":"FeatureCollection","features":[{"type":"Feature",
         "properties":{"aagis_code":"05","aagis_name":"Western Australia"},
         "geometry":{"type":"Point","coordinates":[115.8575,-31.9505]}}]}'
  fake <- mk_resp_text(gj, content_type = "application/geo+json")

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    x <- get_aagis_regions(class = "sf")
  }, .package = "read.abares")

  expect_s3_class(x, "sf")
  expect_true(all(c("aagis_code", "aagis_name") %in% names(x)))
  expect_equal(nrow(x), 1)
})
EOF

# test-get_estimates_by_performance_category.R
cat >"${TEST_DIR}/test-get_estimates_by_performance_category.R" <<'EOF'
test_that("get_estimates_by_performance_category() parses CSV", {
  csv <- "aagis_code,year,category,value\n5,2022,high,0.73\n1,2022,low,0.12\n"
  fake <- mk_resp_text(csv, content_type = "text/csv; charset=utf-8")

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    df <- get_estimates_by_performance_category(year = 2022)
  }, .package = "read.abares")

  expect_s3_class(df, "data.frame")
  expect_true(all(c("aagis_code", "year", "category", "value") %in% names(df)))
  expect_equal(nrow(df), 2)
})
EOF

# test-get_abares_trade_regions.R
cat >"${TEST_DIR}/test-get_abares_trade_regions.R" <<'EOF'
test_that("get_abares_trade_regions() returns expected columns", {
  fake <- mk_resp_json(list(
    items = list(
      list(state = "WA",  code = "5"),
      list(state = "NSW", code = "1")
    )
  ))

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    out <- get_abares_trade_regions(level = "state")
  }, .package = "read.abares")

  expect_s3_class(out, "data.frame")
  expect_true(all(c("state", "code") %in% names(out)))
  expect_true(nrow(out) >= 2)
})
EOF

# test-errors.R
cat >"${TEST_DIR}/test-errors.R" <<'EOF'
test_that("functions surface HTTP errors from .perform_request()", {
  fake_404 <- mk_resp_error(status = 404)

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake_404
    expect_error(get_aagis_regions(class = "sf"), "404|Not Found|HTTP")
  }, .package = "read.abares")
})
EOF

# test-retry_download.R
cat >"${TEST_DIR}/test-retry_download.R" <<'EOF'
test_that(".retry_download() retries on 5xx and then succeeds", {
  calls <- 0L
  with_mocked_bindings({
    .perform_request <- function(req, ...) {
      calls <<- calls + 1L
      if (calls == 1L) mk_resp_error(status = 503) else mk_resp_json(list(ok = TRUE))
    }
    resp <- .retry_download(httr2::request("https://example.test"),
                            max_tries = 3, backoff = 0)
  }, .package = "read.abares")

  expect_equal(calls, 2L)
  expect_s3_class(resp, "httr2_response")
  expect_equal(httr2::resp_status(resp), 200L)
})

test_that(".retry_download() errors after exhausting retries", {
  calls <- 0L
  with_mocked_bindings({
    .perform_request <- function(req, ...) {
      calls <<- calls + 1L
      mk_resp_error(status = 500)
    }
    expect_error(
      .retry_download(httr2::request("https://example.test"),
                      max_tries = 3, backoff = 0),
      "HTTP|500|retry"
    )
  }, .package = "read.abares")

  expect_gte(calls, 3L)
})
EOF
# test-args.R
cat >"${TEST_DIR}/test-args.R" <<'EOF'
test_that("argument validation protects inputs", {
  expect_error(get_abares_trade_regions(level = "bogus"), "level")
  expect_error(get_estimates_by_performance_category(year = "202X"), "year")
  expect_error(get_aagis_regions(class = "sp"), "class|unsupported")
})
EOF

# Ensure tests/testthat.R exists (minimal)
if [ ! -f "${REPO_ROOT}/tests/testthat.R" ]; then
  echo ">> Creating tests/testthat.R"
  cat >"${REPO_ROOT}/tests/testthat.R" <<'EOF'
library(testthat)
library(read.abares)
test_check("read.abares")
EOF
fi

# ------------------------------------------------------------------
# 4) Commit changes
# ------------------------------------------------------------------
echo ">> Staging and committing files"
git add R/http-helpers.R || true
git add R || true
git add tests/testthat || true
git commit -m "tests: add testthat-only mocking; add .perform_request shim; route .retry_download() via shim"

echo ">> Patch applied on branch ${WORK_BRANCH}."
echo ">> Next steps:"
echo "   - Run:   Rscript -e 'devtools::test()'    # or: Rscript -e \"testthat::test_dir('tests/testthat')\""
echo "   - (optional) Coverage: Rscript -e \"cov <- covr::package_coverage(); cat('Coverage: ', covr::percent_coverage(cov), '%\\n', sep='')\""

if [ "${RUN_TESTS:-0}" = "1" ]; then
  echo ">> RUN_TESTS=1 set; running tests and printing coverage if 'covr' is installed."
  Rscript -e "if (!requireNamespace('devtools', quietly=TRUE)) install.packages('devtools', repos=getOption('repos')); devtools::test()"
  Rscript -e "if (requireNamespace('covr', quietly=TRUE)) {cov<-covr::package_coverage(); cat('Coverage: ', covr::percent_coverage(cov), '%\n', sep='')} else {message('covr not installed; skipping coverage.')}"
fi
echo ">> Done."
