#!/usr/local/bin/bash
set -eu

BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PORT="30000"
PYTHON="$HOME/webssh-env/bin/python"
PIDFILE="$BASE_DIR/webssh.pid"
LOGFILE="$BASE_DIR/webssh.log"

find_pids() {
  ps -ax -o pid= -o command= 2>/dev/null |
    awk -v target="$BASE_DIR/run.py" 'index($0, target) > 0 {print $1}'
}

is_webssh_pid() {
  PID="$1"
  case "$PID" in
    ''|*[!0-9]*) return 1 ;;
  esac

  COMMAND="$(ps -p "$PID" -o command= 2>/dev/null || true)"
  case "$COMMAND" in
    *"$BASE_DIR/run.py"*) return 0 ;;
    *) return 1 ;;
  esac
}

get_pid() {
  if [ -f "$PIDFILE" ]; then
    PID="$(cat "$PIDFILE" 2>/dev/null || true)"
    if is_webssh_pid "$PID"; then
      echo "$PID"
      return 0
    fi
    rm -f "$PIDFILE"
  fi

  PID="$(find_pids | head -n 1 || true)"
  if [ -n "$PID" ] && is_webssh_pid "$PID"; then
    echo "$PID"
    return 0
  fi

  return 1
}

check_python() {
  if [ ! -x "$PYTHON" ]; then
    echo "Python virtualenv not found: $PYTHON"
    echo "Create it first:"
    echo "  virtualenv -p python3.10 ~/webssh-env"
    echo "  ~/webssh-env/bin/pip install -r $BASE_DIR/requirements.txt"
    exit 1
  fi
}

start() {
  check_python

  if PID="$(get_pid)"; then
    echo "WebSSH is already running, PID=$PID"
    return 0
  fi

  cd "$BASE_DIR"

  nohup "$PYTHON" "$BASE_DIR/run.py"     --address=127.0.0.1     --port="$PORT"     --xheaders=True     --policy=warning     --wpintvl=30     >> "$LOGFILE" 2>&1 &

  PID=$!
  echo "$PID" > "$PIDFILE"

  sleep 1

  if is_webssh_pid "$PID"; then
    echo "WebSSH started: PID=$PID"
    echo "Listening on 127.0.0.1:$PORT"
    echo "Log: $LOGFILE"
  else
    rm -f "$PIDFILE"
    echo "WebSSH failed to start. Check: $LOGFILE"
    exit 1
  fi
}

stop() {
  if ! PID="$(get_pid)"; then
    echo "WebSSH is not running."
    rm -f "$PIDFILE"
    return 0
  fi

  echo "Stopping WebSSH, PID=$PID..."
  kill "$PID" 2>/dev/null || true

  i=0
  while [ "$i" -lt 10 ]; do
    if ! is_webssh_pid "$PID"; then
      rm -f "$PIDFILE"
      echo "WebSSH stopped."
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done

  echo "WebSSH did not stop gracefully. Sending SIGKILL..."
  kill -9 "$PID" 2>/dev/null || true
  rm -f "$PIDFILE"
  echo "WebSSH stopped."
}

status() {
  if PID="$(get_pid)"; then
    echo "WebSSH is running."
    echo "PID: $PID"
    echo "Listening: 127.0.0.1:$PORT"
    echo "Log: $LOGFILE"
    return 0
  fi

  echo "WebSSH is not running."
  return 1
}

case "${1:-start}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 2
    ;;
esac
