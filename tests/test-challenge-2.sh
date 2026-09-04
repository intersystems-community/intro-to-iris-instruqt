#!/bin/bash
# Tests for 02-challenge-2/check-iris
#
# The check: pass iff a product row with SKU='SKU-976' exists.
#   msg = "Have you inserted the new product into the database?"
# Single check, two possible outcomes.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./helpers.sh
source "${DIR}/helpers.sh"
CHECK="${REPO_ROOT}/02-challenge-2/check-iris"

echo "== Challenge 2: SQL insert of Gummy Rings =="

# Case 1: product not yet inserted -> FAIL with the insert prompt
begin_case "product absent -> fails with insert prompt"
product_absent
run_check "$CHECK"
assert_fail_with "Have you inserted the new product into the database?"
end_case

# Case 2: product present -> PASS
begin_case "product present -> passes"
product_present
run_check "$CHECK"
assert_pass
end_case
