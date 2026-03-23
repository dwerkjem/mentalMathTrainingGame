#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ENV_FILE="$ROOT_DIR/.env"

if ! command -v rclone >/dev/null 2>&1; then
  echo "rclone is not installed locally. Install it first, then rerun this script." >&2
  exit 1
fi

get_env_value() {
  local key="$1"
  local file="$2"
  [ -f "$file" ] || return 0
  python3 - "$key" "$file" <<'PY2'
import sys
from pathlib import Path
key, path = sys.argv[1], Path(sys.argv[2])
for line in path.read_text().splitlines():
    line = line.strip()
    if not line or line.startswith('#') or '=' not in line:
        continue
    k, v = line.split('=', 1)
    if k == key:
        print(v)
        break
PY2
}

REMOTE_TYPE=$(get_env_value RCLONE_REMOTE_TYPE "$ENV_FILE")
SCOPE=$(get_env_value RCLONE_SCOPE "$ENV_FILE")
REMOTE_TYPE=${REMOTE_TYPE:-drive}
SCOPE=${SCOPE:-drive}

TMP_OUTPUT=$(mktemp)
cleanup() {
  rm -f "$TMP_OUTPUT"
}
trap cleanup EXIT

echo "Opening local browser auth for rclone backend '$REMOTE_TYPE' with scope '$SCOPE'."
echo "After authorization completes, this script will update $ENV_FILE with RCLONE_TOKEN."

rclone authorize "$REMOTE_TYPE" scope "$SCOPE" | tee "$TMP_OUTPUT"

TOKEN_JSON=$(python3 - "$TMP_OUTPUT" <<'PY2'
import json
import sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
decoder = json.JSONDecoder()
found = None
for i, ch in enumerate(text):
    if ch != '{':
        continue
    try:
        obj, _ = decoder.raw_decode(text[i:])
    except Exception:
        continue
    if isinstance(obj, dict):
        if 'token' in obj and isinstance(obj['token'], dict):
            found = obj['token']
        elif 'access_token' in obj:
            found = obj
if found is None:
    raise SystemExit('Could not extract an rclone token from authorize output.')
print(json.dumps(found, separators=(',', ':')))
PY2
)

python3 - "$ENV_FILE" "$TOKEN_JSON" <<'PY2'
import sys
from pathlib import Path
path = Path(sys.argv[1])
token = sys.argv[2]
lines = path.read_text().splitlines() if path.exists() else []
out = []
replaced = False
for line in lines:
    if line.startswith('RCLONE_TOKEN='):
        out.append(f'RCLONE_TOKEN={token}')
        replaced = True
    else:
        out.append(line)
if not replaced:
    if out and out[-1] != '':
        out.append('')
    if '# -- Rclone Configuration -- #' not in out:
        out.append('# -- Rclone Configuration -- #')
    out.append(f'RCLONE_TOKEN={token}')
path.write_text('\n'.join(out) + '\n')
PY2

echo
printf 'Saved RCLONE_TOKEN to %s\n' "$ENV_FILE"
echo "Restart the container to apply it:"
echo "  docker compose up -d rclone"
