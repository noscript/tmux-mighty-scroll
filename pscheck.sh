# Copyright (C) 2020 Sergey Vlasov <sergey@vlasov.me>
# MIT License

set -e

if [ $# -lt 3 ]; then
  BASENAME=$(basename $0)
  echo "$BASENAME: too few arguments"
  echo "usage: $BASENAME PID NAME..."
  exit 2
fi

PID=$1; shift
NAMES=$@

walk() {
  for P in $@; do
    if [ ! -f /proc/$P/comm ]; then # process no longer exists or something else
      continue
    fi
    CMD_NAME=$(cat /proc/$P/comm)
    for N in $NAMES; do
      if [ "$N" = "$CMD_NAME" ]; then # it's a match
        echo "$N"
        exit 0
      fi
    done

    CHILDREN=$(cat /proc/$P/task/$P/children)
    if [ ! -z "$CHILDREN" ]; then
      walk $CHILDREN
    fi
  done
}

walk $PID
exit 1
