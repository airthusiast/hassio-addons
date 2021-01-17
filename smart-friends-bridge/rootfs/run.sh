#!/usr/bin/env ash

# Extract config data
CONFIG_PATH=/data/options.json

# Run Node.JS in foreground
exec node node_modules/smart-friends-bridge $CONFIG_PATH
