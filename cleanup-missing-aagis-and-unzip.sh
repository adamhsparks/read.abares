#!/usr/bin/env bash
set -euo pipefail

echo ">> read.abares: cleaning tests that reference non-existent functions and fixing unzip cleanup"

# Ensure we are at the package root
[ -d "R" ] || {
  echo "!! R/ not found. Run this from the package root."
  exit 1
}
mkdir -p tests/testthat

###############################################################################
# 1) Remove test files that reference functions not present on rOpenSci-review
###############################################################################

# Remove aagis-specific tests (function not present on this branch)
if [ -f tests/testthat/test-get_aagis_regions.R ]; then
  echo ">> Removing tests/testthat/test-get_aagis_regions.R (function not present)"
  rm -f tests/testthat/test-get_aagis_regions.R
fi

# Remove generic error test that targeted get_aagis_regions
if [ -f tests/testthat/test-errors.R ]; then
  echo ">> Removing tests/testthat/test-errors.R (was tied to aagis function)"
  rm -f tests/testthat/test-errors.R
fi

# Remove the estimates test if still present from earlier patches
if [ -f tests/testthat/test-get_estimates_by_performance_category.R ]; then
  echo ">> Removing tests/testthat/test-get_estimates_by_performance_category.R (function not present)"
  rm -f tests/testthat/test-get_estimates_by_performance_category.R
fi

###############################################################################
# 2) Clean references inside test-args.R to non-existent functions
###############################################################################
if [ -f tests/testthat/test-args.R ]; then
  echo ">> Cleaning references in tests/testthat/test-args.R"
  # Drop any expect_error lines that call get_aagis_regions() or get_estimates_by_performance_category()
  perl -pi -e 's/^\s*expect_error\(\s*get_aagis_regions\(.*\)\s*,\s*.*\)\s*\n//g' tests/testthat/test-args.R
  perl -pi -e 's/^\s*expect_error\(\s*get_estimates_by_performance_category\(.*\)\s*,\s*.*\)\s*\n//g' tests/testthat/test-args.R
fi

###############################################################################
# 3) Make unzip cleanup vector-safe via a helper and rewrite deletions
###############################################################################
UNZIP_FILE="R/unzip_file.R"
if [ -f "$UNZIP_FILE" ]; then
  echo ">> Ensuring vector-safe .safe_delete() helper exists in $UNZIP_FILE"
  if ! grep -q "\.safe_delete" "$UNZIP_FILE"; then
    cat >>"$UNZIP_FILE" <<'EOF'

#' Delete only existing files (vector-safe)
#' @keywords internal
#' @noRd
.safe_delete <- function(x) {
  x <- x[fs::file_exists(x)]
  if (length(x)) fs::file_delete(x)
  invisible(NULL)
}
EOF
  fi

  echo ">> Rewriting any fs::file_delete(...) to use .safe_delete(...) in $UNZIP_FILE"
  # If there are guards like if (fs::file_exists(x)) fs::file_delete(x) -> .safe_delete(x)
  perl -0777 -pe 's/if\s*\(\s*fs::file_exists\(\s*([^)]+?)\s*\)\s*\)\s*fs::file_delete\(\s*\1\s*\)/.safe_delete(\1)/g' -i "$UNZIP_FILE"
  # Replace any remaining direct fs::file_delete(expr) -> .safe_delete(expr)
  perl -0777 -pe 's/fs::file_delete\(\s*([^)]+?)\s*\)/.safe_delete(\1)/g' -i "$UNZIP_FILE"
else
  echo ">> $UNZIP_FILE not found; skipping unzip patch."
fi

###############################################################################
# 4) Ensure a small file-writing helper exists (used by some file-reading tests)
###############################################################################
if [ ! -f tests/testthat/helper-utils.R ]; then
  echo ">> Adding tests/testthat/helper-utils.R (write_csv_payload)"
  cat >tests/testthat/helper-utils.R <<'EOF'
write_csv_payload <- function(path, text) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  con <- file(path, open = "wb"); on.exit(close(con), add = TRUE)
  writeBin(charToRaw(enc2utf8(text)), con)
  normalizePath(path, mustWork = TRUE)
}
EOF
fi

###############################################################################
# 5) Stage & commit (if in a Git repo)
###############################################################################
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A
  git commit -m "tests: remove aagis/estimates tests; drop invalid arg assertions; vector-safe delete in unzip_file.R; add helper" || true
fi
echo ">> Patch applied. Now run:"
echo "   Rscript -e \"devtools::test()\""
