#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SOURCE_CONFIG=${1:-$HOME/.config/rclone/rclone.conf}
TARGET_DIR="$ROOT_DIR/rclone"
TARGET_CONFIG="$TARGET_DIR/rclone.conf"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$SOURCE_CONFIG" ]; then
  echo "Source rclone config not found: $SOURCE_CONFIG" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
chmod 600 "$TARGET_CONFIG"

python3 - "$ENV_FILE" <<'PY2'
import sys
from pathlib import Path
path = Path(sys.argv[1])
entry = 'RCLONE_CONFIG_PATH=./rclone/rclone.conf'
lines = path.read_text().splitlines() if path.exists() else []
out = []
replaced = False
for line in lines:
    if line.startswith('RCLONE_CONFIG_PATH='):
        out.append(entry)
        replaced = True
    else:
        out.append(line)
if not replaced:
    if out and out[-1] != '':
        out.append('')
    if '# -- Rclone Configuration -- #' not in out:
        out.append('# -- Rclone Configuration -- #')
    out.append(entry)
path.write_text('\n'.join(out) + '\n')
PY2

echo "Copied rclone config to $TARGET_CONFIG"
echo "Updated $ENV_FILE to use the repo-local config path."
echo "Restart with: docker compose up -d rclone"
