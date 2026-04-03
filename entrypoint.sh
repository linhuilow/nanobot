#!/bin/sh
# Write config from env var if config file doesn't already exist
mkdir -p /root/.nanobot
if [ ! -f /root/.nanobot/config.json ] && [ -n "$NANOBOT_CONFIG" ]; then
  # Use Python to validate and write the config so that any unescaped control
  # characters in the environment variable are caught before they can produce
  # malformed JSON that would crash nanobot at startup.
  python3 - <<'EOF'
import json
import os
import sys

raw = os.environ.get("NANOBOT_CONFIG", "")
dest = "/root/.nanobot/config.json"

try:
    parsed = json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"ERROR: NANOBOT_CONFIG is not valid JSON ({exc}). Falling back to default config.", file=sys.stderr)
    sys.exit(0)

with open(dest, "w") as f:
    json.dump(parsed, f, indent=2)

print("Config written from NANOBOT_CONFIG env var.")
EOF
fi
exec nanobot gateway
