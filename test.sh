set -e

case "$OSTYPE" in
  "darwin"*)
    echo "macOS is not supported"
    exit 1
    ;;
esac

cd "$(dirname "$0")"

TARGET_PID=$$ # PID of benchmark.sh

clean() {
  if [ ! -z $PID ]; then
    kill $PID
  fi
}
trap clean 0 1 2 3 6 15

run_test() {
  EXPECTED_EXIT_CODE=$1; shift
  echo
  echo Running: \"$@\"
  (
    set +e
    eval "$@"
    EXIT_CODE=$?
    echo "Exit code $EXIT_CODE, expected $EXPECTED_EXIT_CODE"
    if [ "$EXIT_CODE" != "$EXPECTED_EXIT_CODE" ]; then
      echo "FAILED"
      exit 1
    fi
    echo "PASSED"
  )
}

run_suit() {
  EXPECTED_EXIT_CODE=$1; shift
  COMMAND="$1"; shift
  echo ----------------------------
  echo Command: \"$COMMAND\"
  echo Process names to match: $@
  echo Expected exit code: $EXPECTED_EXIT_CODE

  eval "$COMMAND" &
  PID=$!
  sleep 1 # give processes time to start

  echo Process tree:
  pstree -g $TARGET_PID
  echo

  run_test $EXPECTED_EXIT_CODE "./pscheck.sh $TARGET_PID $@"
  run_test $EXPECTED_EXIT_CODE "./pscheck $TARGET_PID $@"

  kill -KILL $PID
  PID=
  echo
}

run_suit 1 'timeout 5 tail -f /dev/null' 'dummy'
run_suit 0 'timeout 5 tail -f /dev/null' 'dummy' 'tail'
run_suit 1 'timeout -s STOP -k 5 0.5 tail -f /dev/null' 'dummy' 'tail'
