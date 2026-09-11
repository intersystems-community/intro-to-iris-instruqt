#!/bin/bash
# Tests for 05-challenge-5/check-iris
#
# This check has TWO sub-checks (intended behavior):
#   1. Total UnitsSold for SKU-976 is at least the order the learner is told to
#      place (the assignment says 100 units).
#        fail msg: "Have you submitted an order for 100 units?"
#   2. ^HoleFoodsQuiz is truthy (learner answered the quiz correctly).
#        fail msg: "Have you got the correct answer in the Quiz?"
#
# The assignment tells the learner to place an order for 100 units, so exactly
# 100 units must pass sub-check 1. Sub-check 2 must fail with its own quiz
# message when the quiz is wrong (not the units message). Each case sets the
# other condition to good and breaks exactly one, so a failure isolates a
# single sub-check.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./helpers.sh
source "${DIR}/helpers.sh"
CHECK="${REPO_ROOT}/05-challenge-5/check-iris"

echo "== Challenge 5: analytics order + quiz =="

# Case 1: no order + no quiz -> fails on the units prompt
begin_case "no order, quiz unanswered -> fails units prompt"
clear_sales
set_quiz 0
run_check "$CHECK"
assert_fail_with "Have you submitted an order for 100 units?"
end_case

# Case 2: exactly 100 units, quiz correct -> should PASS (intended per assignment)
begin_case "exactly 100 units + quiz correct -> passes (intended)"
clear_sales
add_sale 100
set_quiz 1
run_check "$CHECK"
assert_pass
end_case

# Case 3: plenty of units (150), quiz correct -> passes (unambiguous, above any threshold)
begin_case "150 units + quiz correct -> passes"
clear_sales
add_sale 150
set_quiz 1
run_check "$CHECK"
assert_pass
end_case

# Case 4: enough units but quiz wrong -> fails with the QUIZ message (intended)
begin_case "150 units but quiz wrong -> fails with quiz prompt"
clear_sales
add_sale 150
set_quiz 0
run_check "$CHECK"
assert_not_fail_with "Have you submitted an order for 100 units?"
assert_fail_with "Have you got the correct answer in the Quiz?"
end_case

# cleanup
clear_sales
set_quiz 0
