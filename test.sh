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
  if [ ! -z $SCREEN_PID ]; then
    kill $SCREEN_PID
  fi
}
trap clean 0 1 2 3 6 15

run_test() {
  EXPECTED_EXIT_CODE=$1; shift
  echo -n Running: \"$@\"
  (
    set +e
    eval "$@" >/dev/null
    EXIT_CODE=$?
    if [ "$EXIT_CODE" != "$EXPECTED_EXIT_CODE" ]; then
      echo " : exit code $EXIT_CODE != $EXPECTED_EXIT_CODE"
      exit 1
    fi
    echo " : passed, exit code $EXIT_CODE"
  )
}

run_suit() {
  EXPECTED_EXIT_CODE=$1; shift
  echo Pager command: \"$@\"
  echo Expected exit code: $EXPECTED_EXIT_CODE

  screen -Dm "$@" &
  SCREEN_PID=$!
  sleep 1 # give processes time to start

  echo Process tree:
  pstree -g $TARGET_PID
  echo

  run_test $EXPECTED_EXIT_CODE "pstree $TARGET_PID | grep 'man\|less\|pager'"
  run_test $EXPECTED_EXIT_CODE "./pscheck.sh $TARGET_PID 'man' 'less' 'pager'"
  run_test $EXPECTED_EXIT_CODE "./pscheck $TARGET_PID 'man' 'less' 'pager'"

  kill $SCREEN_PID
  SCREEN_PID=
  echo
}

run_suit 0 man ascii
run_suit 1 bash
