# shellcheck shell=bash
# Shared helpers for the check-script test suite.
#
# The suite runs the REAL check scripts (04-challenge-4/check-iris etc.) verbatim
# inside the running local container, exactly as Instruqt would on the VM:
#   docker exec --user root <container> bash -s < <check-script>
# The check scripts themselves do `su - irisowner` before talking to IRIS, so we
# must exec as root (just like the Instruqt VM, where checks run as root).
#
# Between cases we drive IRIS state directly with `iris session` as irisowner.

set -uo pipefail

CONTAINER="${IRIS_CONTAINER:-intro-to-iris-iris-1}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---- counters (init once; suites re-source this file, so guard the reset) ----
: "${TESTS_RUN:=0}"
: "${TESTS_PASS:=0}"
: "${TESTS_FAIL:=0}"
CURRENT_CASE=""

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

# ---------------------------------------------------------------------------
# IRIS access
# ---------------------------------------------------------------------------

# iris_do <objectscript...>  -- pipe ObjectScript into a USER-namespace session
# (runs as the container's default user, irisowner). Used for state setup only.
iris_do() {
  docker exec -i "$CONTAINER" iris session iris -UUSER 2>&1
}

# run_check <path-to-check-script>
# Runs the actual check script the way Instruqt does (as root) and captures
# stdout+stderr into $CHECK_OUTPUT and the exit code into $CHECK_EXIT.
run_check() {
  local script="$1"
  CHECK_OUTPUT="$(docker exec -i --user root "$CONTAINER" bash -s < "$script" 2>&1)"
  CHECK_EXIT=$?
}

# ---------------------------------------------------------------------------
# case management + assertions
# ---------------------------------------------------------------------------

begin_case() {
  CURRENT_CASE="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  CASE_FAILED=0
  CASE_MESSAGES=()
}

_case_fail() {
  CASE_FAILED=1
  CASE_MESSAGES+=("$1")
}

end_case() {
  if [ "$CASE_FAILED" -eq 0 ]; then
    TESTS_PASS=$((TESTS_PASS + 1))
    printf '  %sPASS%s  %s\n' "$GREEN" "$RESET" "$CURRENT_CASE"
  else
    TESTS_FAIL=$((TESTS_FAIL + 1))
    printf '  %sFAIL%s  %s\n' "$RED" "$RESET" "$CURRENT_CASE"
    local m
    for m in "${CASE_MESSAGES[@]}"; do
      printf '        %s%s%s\n' "$YELLOW" "$m" "$RESET"
    done
    printf '        --- check output ---\n'
    printf '%s\n' "$CHECK_OUTPUT" | sed 's/^/        | /'
    printf '        --- exit: %s ---\n' "$CHECK_EXIT"
  fi
}

# assert_pass -- the check should have SUCCEEDED (exit 0, no FAIL: lines)
assert_pass() {
  if [ "$CHECK_EXIT" -ne 0 ]; then
    _case_fail "expected check to PASS (exit 0) but exit was $CHECK_EXIT"
  fi
  if printf '%s' "$CHECK_OUTPUT" | grep -q '^FAIL: '; then
    _case_fail "expected check to PASS but it emitted a FAIL: line"
  fi
}

# assert_fail_with "<expected message substring>"
# the check should have FAILED (non-zero exit) with a FAIL: line containing the text
assert_fail_with() {
  local expected="$1"
  if [ "$CHECK_EXIT" -eq 0 ]; then
    _case_fail "expected check to FAIL (non-zero exit) but exit was 0"
  fi
  if ! printf '%s' "$CHECK_OUTPUT" | grep -qF "FAIL: ${expected}"; then
    _case_fail "expected a FAIL: line containing: ${expected}"
  fi
}

# assert_not_fail_with "<message substring>"
# the check must NOT emit this particular FAIL message (used to prove an earlier
# sub-check passed and a later sub-check was reached).
assert_not_fail_with() {
  local unexpected="$1"
  if printf '%s' "$CHECK_OUTPUT" | grep -qF "FAIL: ${unexpected}"; then
    _case_fail "did NOT expect a FAIL: line containing: ${unexpected}"
  fi
}

# ---------------------------------------------------------------------------
# state setup helpers  (SKU-976 = "Gummy Rings", the narrative product)
# ---------------------------------------------------------------------------

product_present() {
  iris_do <<'EOF' >/dev/null
set r=##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM HoleFoods.Product WHERE SKU='SKU-976'")
if 'r.%Next() {
  set i=##class(%SQL.Statement).%ExecDirect(,"INSERT INTO HoleFoods.Product (Category,Name,Price,SKU,Stock) VALUES ('Snack','Gummy Rings',2.99,'SKU-976',200)")
}
halt
EOF
}

product_absent() {
  iris_do <<'EOF' >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM HoleFoods.SalesTransaction WHERE Product->SKU='SKU-976'")
do ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM HoleFoods.Product WHERE SKU='SKU-976'")
halt
EOF
}

# set_stock <n>  -- ensure product exists then set its Stock
set_stock() {
  local n="$1"
  product_present
  iris_do <<EOF >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"UPDATE HoleFoods.Product SET Stock=${n} WHERE SKU='SKU-976'")
halt
EOF
}

# add_sale <units>  -- insert one SalesTransaction of <units> for SKU-976
add_sale() {
  local units="$1"
  product_present
  iris_do <<EOF >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"INSERT INTO HoleFoods.SalesTransaction (Product,Outlet,UnitsSold,DateTimeOfSale,AmountOfSale) VALUES ('SKU-976',1,${units},CURRENT_TIMESTAMP,${units}*2.99)")
halt
EOF
}

clear_sales() {
  iris_do <<'EOF' >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM HoleFoods.SalesTransaction WHERE Product->SKU='SKU-976'")
halt
EOF
}

# set_quiz <0|1>  -- matches production: setup initializes ^HoleFoodsQuiz to 0
# (answered wrong / not yet correct), and answering correctly sets it to 1.
set_quiz() {
  local v="$1"
  iris_do <<EOF >/dev/null
set ^HoleFoodsQuiz=${v}
halt
EOF
}

# toemail_enabled <0|1>  -- enable/disable the ToEmail production item
toemail_enabled() {
  local v="$1"
  iris_do <<EOF >/dev/null
do ##class(Ens.Director).EnableConfigItem("ToEmail",${v},1)
halt
EOF
}

# add_email_log  -- insert an Ens_Util.Log row proving ToEmail::SendMail ran
add_email_log() {
  iris_do <<'EOF' >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"INSERT INTO Ens_Util.Log (ConfigName,SourceMethod,Type,Text) VALUES ('ToEmail','SendMail',3,'test-sendmail')")
halt
EOF
}

clear_email_log() {
  iris_do <<'EOF' >/dev/null
do ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM Ens_Util.Log WHERE ConfigName='ToEmail' AND SourceMethod='SendMail'")
halt
EOF
}

print_summary() {
  echo
  printf '%s========================================%s\n' "$BOLD" "$RESET"
  printf '%sTotal: %d   %sPASS: %d%s   %sFAIL: %d%s\n' \
    "$BOLD" "$TESTS_RUN" "$GREEN" "$TESTS_PASS" "$RESET" "$RED" "$TESTS_FAIL" "$RESET"
  printf '%s========================================%s\n' "$BOLD" "$RESET"
  [ "$TESTS_FAIL" -eq 0 ]
}
