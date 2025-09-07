#!/usr/bin/env bash
set -euo pipefail

echo ">> Applying cleanups for missing function tests and unzip cleanup"

# Ensure we are at the package root
[ -d "R" ] || {
  echo "!! R/ not found. Run this from the package root."
  exit 1
}
mkdir -p tests/testthat

# 1) Remove the test file that targets a non-existent function
if [ -f tests/testthat/test-get_estimates_by_performance_category.R ]; then
  echo ">> Removing tests/testthat/test-get_estimates_by_performance_category.R"
  rm -f tests/testthat/test-get_estimates_by_performance_category.R
fi

# 2) Remove any leftover assertion lines that call the non-existent function
if [ -f tests/testthat/test-args.R ]; then
  echo ">> Cleaning references to get_estimates_by_performance_category() in test-args.R"
  perl -pi -e 's/^\s*expect_error\(\s*get_estimates_by_performance_category\(.*\)\s*,\s*.*\)\s*\n//g' tests/testthat/test-args.R
fi

# 3) Make deletion in unzip_file.R robust for vectors:
#    delete only paths that exist, and handle length > 1 cleanly
if [ -f R/unzip_file.R ]; then
  echo ">> Vectorising fs::file_delete() in R/unzip_file.R"
  # Replace any occurrence of fs::file_delete(x) with fs::file_delete(x[fs::file_exists(x)])
  # Works whether x is a scalar or a character vector
  perl -0777 -pe '
    s/fs::file_delete\(\s*([^)]+?)\s*\)/fs::file_delete(\1[fs::file_exists(\1)])/g
  ' -i R/unzip_file.R
else
  echo ">> R/unzip_file.R not found; skipping unzip patch."
fi

# 4) Stage & commit (if in a git repo)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A
  git commit -m "tests: remove missing get_estimates_by_performance_category tests; vectorise safe delete in unzip" || true
fi

echo ">> Done. Now run:"
echo "   Rscript -e \"devtools::test()\""
