#!/bin/sh
# Validate and/or write config.json on every startup.
#
# If a config file already exists on the persistent volume, validate it first.
# A malformed file (e.g. unescaped control characters from a previous bad write)
# is deleted so nanobot never tries to load invalid JSON.  After any deletion,
# or when no file exists at all, the file is recreated from NANOBOT_CONFIG if
# that env var is set.  If neither a valid file nor the env var is present,
# nanobot falls back to its built-in defaults.
mkdir -p /root/.nanobot
python3 - <<'EOF'
import json
import os
import sys

dest = "/root/.nanobot/config.json"
raw  = os.environ.get("NANOBOT_CONFIG", "")

# --- Step 1: validate any existing config file ---
if os.path.exists(dest):
    try:
        with open(dest, "r") as f:
            json.load(f)
        print("Config file is valid JSON — no changes needed.")
        sys.exit(0)
    except (json.JSONDecodeError, OSError) as exc:
        print(f"WARNING: Existing config file is invalid ({exc}). Deleting it.", file=sys.stderr)
        os.remove(dest)

# --- Step 2: recreate from env var if available ---
if not raw:
    print("No NANOBOT_CONFIG set and no valid config file — nanobot will use defaults.")
    sys.exit(0)

try:
    parsed = json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"ERROR: NANOBOT_CONFIG is not valid JSON ({exc}). Falling back to default config.", file=sys.stderr)
    sys.exit(0)

with open(dest, "w") as f:
    json.dump(parsed, f, indent=2)

print("Config written from NANOBOT_CONFIG env var.")
EOF
exec nanobot gateway
