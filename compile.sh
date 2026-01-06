#!/usr/bin/env sh

TF=$(mktemp)
mise x -- deps --require-as-include -c core.fnl > "$TF"
mv -f "$TF" init.lua
