#!/bin/bash
# permissions.sh
# this is called by a git post merge hook, don't move it
# Make incommon/{executable,library} group-readable and non-group-writable,
# preserving existing execute bits (via X).

set -euo pipefail

base='.'

# 1. Let group members enter the top-level incommon directory
chmod g+rx "$base"

# 2. Fix permissions on executable/ and library/ subtrees
for sub in executable library; do
  if [ -d "$base/$sub" ]; then
    chmod -R g+rX,g-w "$base/$sub"
  else
    echo "Note: $base/$sub does not exist, skipping" >&2
  fi
done
