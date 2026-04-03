#!/bin/sh
# Write config from env var if config file doesn't already exist
mkdir -p /root/.nanobot
if [ ! -f /root/.nanobot/config.json ] && [ -n "$NANOBOT_CONFIG" ]; then
  printf '%s' "$NANOBOT_CONFIG" > /root/.nanobot/config.json
  echo "Config written from NANOBOT_CONFIG env var."
fi
exec nanobot gateway
