#!/usr/bin/env bash

set -euo pipefail

MAX_PROFILES=5
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git-persona-bar"
CONFIG_FILE="$CONFIG_DIR/profiles.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_FILE="$REPO_ROOT/config/profiles.example.json"

mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
  if [ -f "$EXAMPLE_FILE" ]; then
    cp "$EXAMPLE_FILE" "$CONFIG_FILE"
  else
    cat > "$CONFIG_FILE" <<'JSON'
{
  "profiles": []
}
JSON
  fi
fi

echo "Git Persona Bar - Add Profile"
echo "Config: $CONFIG_FILE"
echo

read -rp "Profile id (e.g. work, personal, client-a): " PROFILE_ID
if [[ ! "$PROFILE_ID" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: id must match [a-zA-Z0-9_-]"
  exit 1
fi

DEFAULT_LABEL="$PROFILE_ID"
read -rp "Label [$DEFAULT_LABEL]: " PROFILE_LABEL
PROFILE_LABEL="${PROFILE_LABEL:-$DEFAULT_LABEL}"

read -rp "Icon [👤]: " PROFILE_ICON
PROFILE_ICON="${PROFILE_ICON:-👤}"

read -rp "Git user.name: " GIT_NAME
read -rp "Git user.email: " GIT_EMAIL

read -rp "SSH host [github.com]: " SSH_HOST
SSH_HOST="${SSH_HOST:-github.com}"

read -rp "SSH identity file [~/.ssh/id_ed25519]: " SSH_KEY
SSH_KEY="${SSH_KEY:-~/.ssh/id_ed25519}"

python3 - "$CONFIG_FILE" "$MAX_PROFILES" "$PROFILE_ID" "$PROFILE_LABEL" "$PROFILE_ICON" "$GIT_NAME" "$GIT_EMAIL" "$SSH_HOST" "$SSH_KEY" <<'PY'
import json, os, re, sys

(config_file, max_profiles, pid, label, icon, gname, gemail, shost, skey) = sys.argv[1:]
max_profiles = int(max_profiles)

if not gname.strip() or not gemail.strip():
    print('Error: git name/email are required')
    sys.exit(1)

with open(config_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

profiles = data.get('profiles', [])
if not isinstance(profiles, list):
    print('Error: config has invalid "profiles" field')
    sys.exit(1)

for p in profiles:
    if (p.get('id') or '').strip() == pid:
        print(f'Error: profile id "{pid}" already exists')
        sys.exit(1)

if len(profiles) >= max_profiles:
    print(f'Error: max profiles reached ({max_profiles})')
    sys.exit(1)

profiles.append({
    'id': pid,
    'label': label,
    'icon': icon,
    'git': {
        'name': gname,
        'email': gemail,
    },
    'ssh': {
        'host': shost,
        'identity_file': skey,
    },
})

data['profiles'] = profiles

with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)
    f.write('\n')

print(f'Added profile "{pid}". Total profiles: {len(profiles)}')
PY

echo
if command -v open >/dev/null 2>&1; then
  read -rp "Open config file now? [y/N]: " OPEN_NOW
  if [[ "${OPEN_NOW:-}" =~ ^[Yy]$ ]]; then
    open "$CONFIG_FILE"
  fi
fi

echo "Done. Use SwiftBar menu to switch profiles."
