# Copyright (C) 2022 Sergey Vlasov <sergey@vlasov.me>
# MIT License

if [ $# -lt 2 ]; then
  BASENAME=$(basename $0)
  echo "$BASENAME: too few arguments"
  echo "usage: $BASENAME PID NAME..."
  exit 2
fi

PID=$1; shift
NAMES=$@

process_name() {
  case "$OSTYPE" in
    "darwin"*)
      ps -p $1 -o comm=
      ;;
    *)
      if [ -f /proc/$1/comm ]; then
        cat /proc/$P/comm
      fi
      ;;
  esac
}

process_children() {
  case "$OSTYPE" in
    "darwin"*)
      pgrep -P $1 -a
      ;;
    *)
      cat /proc/$1/task/$1/children
      ;;
  esac
}

walk() {
  for P in $@; do
    CMD_NAME="$(process_name $P)"
    if [ -z "$CMD_NAME" ]; then # process no longer exists or something else
      continue
    fi

    for N in $NAMES; do
      if [ "$N" = "$CMD_NAME" ]; then # it's a match
        echo "$N"
        exit 0
      fi
    done

    CHILDREN=$(process_children $P)
    if [ ! -z "$CHILDREN" ]; then
      walk $CHILDREN
    fi
  done
}

walk $PID
exit 1
