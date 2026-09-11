#!/bin/bash
# Tests for 03-challenge-3/check-iris
#
# The check: pass iff SKU-976 exists AND Stock=300 (restocked from 200 by +100).
#   msg = "Have you restocked the Gummy Rings?"
# Single check. Note the check requires EXACTLY Stock=300.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./helpers.sh
source "${DIR}/helpers.sh"
CHECK="${REPO_ROOT}/03-challenge-3/check-iris"

echo "== Challenge 3: restock Gummy Rings to 300 =="

# Case 1: still at initial stock 200 -> FAIL
begin_case "stock still 200 (not restocked) -> fails"
set_stock 200
run_check "$CHECK"
assert_fail_with "Have you restocked the Gummy Rings?"
end_case

# Case 2: restocked to exactly 300 -> PASS
begin_case "stock = 300 -> passes"
set_stock 300
run_check "$CHECK"
assert_pass
end_case

# Case 3: product missing entirely -> FAIL (no row matches)
begin_case "product absent -> fails"
product_absent
run_check "$CHECK"
assert_fail_with "Have you restocked the Gummy Rings?"
end_case

# Case 4: stock some other value (e.g. 250) -> FAIL, check demands exactly 300
begin_case "stock = 250 (partial) -> fails (exact-300 requirement)"
set_stock 250
run_check "$CHECK"
assert_fail_with "Have you restocked the Gummy Rings?"
end_case
