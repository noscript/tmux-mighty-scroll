set -e

case "$OSTYPE" in
  "darwin"*)
    echo "macOS is not supported"
    exit 1
    ;;
esac

cd "$(dirname "$0")"

TARGET_PID=$$ # PID of benchmark.sh
RUN_NUM=100
PAGER_CMD="man ascii"

clean() {
  if [ ! -z $SCREEN_PID ]; then
    kill $SCREEN_PID
  fi
}
trap clean 0 1 2 3 6 15

run_benchmark() {
  echo Running: \"$@\"
  TOTAL=0
  i=1
  while [ "$i" -le $RUN_NUM ]; do
    START=$(date +%s.%N)
    eval "$@" >/dev/null
    END=$(date +%s.%N)
    TOTAL=$(echo "$TOTAL + $END - $START" | bc -l)
    echo -n "\r$(( $i * 100 / $RUN_NUM ))%"
    i=$((i + 1))
  done
  echo -e "\rAverage per execution (seconds): $(echo "scale=5; $TOTAL / $RUN_NUM" | bc -l | sed 's/^\./0./')"
  echo
}

echo Execution count: $RUN_NUM

echo Pager command: \"$PAGER_CMD\"
screen -Dm $PAGER_CMD &
SCREEN_PID=$!
sleep 1 # give processes time to start

echo Process tree:
pstree -g $TARGET_PID
echo

run_benchmark "pstree $TARGET_PID | grep 'man\|less\|pager'"
run_benchmark "./pscheck.sh $TARGET_PID 'man' 'less' 'pager'"
run_benchmark "./pscheck $TARGET_PID 'man' 'less' 'pager'"

kill $SCREEN_PID
SCREEN_PID=
