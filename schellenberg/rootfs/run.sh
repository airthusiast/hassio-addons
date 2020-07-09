#!/usr/bin/env ash

# Extract config data
CONFIG_PATH=/data/options.json

# Run Node.JS in foreground
exec node node_modules/schellenbergrestapi $CONFIG_PATH
