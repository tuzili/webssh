#!/usr/local/bin/bash
set -eu

BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PORT="30000"
PYTHON="$HOME/webssh-env/bin/python"
PIDFILE="$BASE_DIR/webssh.pid"
LOGFILE="$BASE_DIR/webssh.log"

if [ ! -x "$PYTHON" ]; then
  echo "Python virtualenv not found: $PYTHON"
  echo "Create it first:"
  echo "  virtualenv -p python3.10 ~/webssh-env"
  echo "  ~/webssh-env/bin/pip install -r $BASE_DIR/requirements.txt"
  exit 1
fi

if [ -f "$PIDFILE" ]; then
  PID="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    echo "WebSSH is already running, PID=$PID"
    exit 0
  fi
  rm -f "$PIDFILE"
fi

cd "$BASE_DIR"

nohup "$PYTHON" "$BASE_DIR/run.py" \
  --address=127.0.0.1 \
  --port="$PORT" \
  --xheaders=True \
  --policy=warning \
  --wpintvl=30 \
  >> "$LOGFILE" 2>&1 &

PID=$!
echo "$PID" > "$PIDFILE"

sleep 1

if kill -0 "$PID" 2>/dev/null; then
  echo "WebSSH started: PID=$PID"
  echo "Listening on 127.0.0.1:$PORT"
  echo "Log: $LOGFILE"
else
  rm -f "$PIDFILE"
  echo "WebSSH failed to start. Check: $LOGFILE"
  exit 1
fi
