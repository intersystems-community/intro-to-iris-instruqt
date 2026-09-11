#!/bin/bash
# Tests for 04-challenge-4/check-iris
#
# This check has THREE sub-checks (intended behavior):
#   1. A SalesTransaction for SKU-976 exists (order submitted via web form)
#        fail msg: "Have you submitted an Order using the web form?"
#   2. The ToEmail production component is functioning (CheckComponentFunctioning)
#        fail msgs: "Have you add the ToEmail to the production?"   (not added)
#                   "Have you ensured the ToEmail component is running?" (added, disabled)
#   3. An Ens_Util.Log row for ConfigName='ToEmail', SourceMethod='SendMail' exists
#        fail msg: "Have you re-submitted an order with the ToEmail functioning?"
#
# All three sub-checks must be reachable: each case below sets every other
# condition to good and breaks exactly one, so a failure isolates a single
# sub-check. The final case satisfies all three and expects a pass.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./helpers.sh
source "${DIR}/helpers.sh"
CHECK="${REPO_ROOT}/04-challenge-4/check-iris"

# Fully-passing state: order placed, ToEmail enabled, SendMail logged.
setup_all_good() {
  clear_email_log
  clear_sales
  add_sale 5
  toemail_enabled 1
  add_email_log
}

echo "== Challenge 4: interop order + email =="

# --- Sub-check 1: web-form order ---

begin_case "no order submitted -> fails with web-form prompt"
setup_all_good
clear_sales                      # remove the order but keep everything else good
run_check "$CHECK"
assert_fail_with "Have you submitted an Order using the web form?"
end_case

# --- Sub-check 2: ToEmail component ---

begin_case "order placed but ToEmail disabled -> fails 'component is running'"
setup_all_good
toemail_enabled 0
run_check "$CHECK"
# sub-check 1 must pass (order exists), so we must NOT see the web-form prompt
assert_not_fail_with "Have you submitted an Order using the web form?"
assert_fail_with "Have you ensured the ToEmail component is running?"
end_case

# --- Sub-check 3: SendMail log ---

begin_case "order + ToEmail running but no SendMail log -> fails re-submit prompt"
setup_all_good
clear_email_log                  # ToEmail present & enabled, but never sent mail
run_check "$CHECK"
assert_not_fail_with "Have you submitted an Order using the web form?"
assert_fail_with "Have you re-submitted an order with the ToEmail functioning?"
end_case

# --- All conditions satisfied ---

begin_case "order + ToEmail running + SendMail logged -> passes"
setup_all_good
run_check "$CHECK"
assert_pass
end_case

# cleanup the log rows we injected so we don't leave test data behind
clear_email_log
