#!/usr/bin/env sh

mise x -- deps --require-as-include -c lib/cljlib-shim.fnl 2>/dev/null > lib/cljlib-shim.lua

# Compile main config, skipping the pre-compiled shim
TF=$(mktemp)
mise x -- deps --require-as-include --skip-include "lib.cljlib-shim" -c core.fnl > "$TF"
mv -f "$TF" init.lua
