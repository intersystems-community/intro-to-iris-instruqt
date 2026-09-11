#!/bin/bash
# Test runner for all check-iris scripts.
#
# The real setup scripts run EVERY time (via setup.sh): the container is
# force-recreated and the full production init progression is executed
# (challenge 1 baked into the image, then c2 setup+solve, c4 setup, c5 setup).
# This is vital -- the tests must exercise the exact same IRIS state that a
# learner faces in production, never hand-faked state. Each test case then
# layers only the learner's action on top of that real baseline.
#
# Usage:
#   tests/run-all.sh            build production state + run all suites
#   tests/run-all.sh 3 5        build production state + run only these challenges
#
# Env:
#   IRIS_CONTAINER   container name (default: intro-to-iris-iris-1)

set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${DIR}/.." && pwd)"
# shellcheck source=./helpers.sh
source "${DIR}/helpers.sh"

CHALLENGES=()
for arg in "$@"; do
  case "$arg" in
    [0-9]*) CHALLENGES+=("$arg") ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done
[ "${#CHALLENGES[@]}" -eq 0 ] && CHALLENGES=(2 3 4 5)

echo "${BOLD}Building production state (running the real setup scripts)...${RESET}"
# setup.sh force-recreates the container and runs the full setup progression,
# exactly as production does. Runs every time so setup-script edits are picked up.
( cd "$REPO_ROOT" && bash setup.sh )

# Verify IRIS answers before running anything.
if ! docker exec -i "$CONTAINER" iris session iris -U%SYS <<<'write "ok",! halt' >/dev/null 2>&1; then
  echo "${RED}Cannot reach IRIS in container '${CONTAINER}' after setup.${RESET}" >&2
  exit 1
fi

for n in "${CHALLENGES[@]}"; do
  suite="${DIR}/test-challenge-${n}.sh"
  if [ ! -f "$suite" ]; then
    echo "${YELLOW}no suite for challenge ${n}, skipping${RESET}"
    continue
  fi
  echo
  # each suite sources helpers.sh itself; run in-process so counters accumulate
  # shellcheck source=/dev/null
  source "$suite"
done

print_summary
