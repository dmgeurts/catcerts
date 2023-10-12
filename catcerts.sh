#!/bin/bash
# concatenate a server cert and the chain (or root cert) into a single file

cert="$1"
chain="$2"
target="$3"

cat "$cert" "$chain" > "$target"
chmod 600 "$target"
