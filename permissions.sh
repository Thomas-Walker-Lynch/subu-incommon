#!/bin/bash
# permissions.sh
# do this after a git clone
# Make incommon/{executable,library} group-readable and non-group-writable,
# preserving existing execute bits (via X).

set -euo pipefail

BASE=${1:-incommon}

if [ ! -d "$BASE" ]; then
  echo "Error: $BASE is not a directory" >&2
  exit 1
fi

# 1. Let group members enter the top-level incommon directory
chmod g+rx "$BASE"

# 2. Fix permissions on executable/ and library/ subtrees
for sub in executable library; do
  if [ -d "$BASE/$sub" ]; then
    chmod -R g+rX,g-w "$BASE/$sub"
  else
    echo "Note: $BASE/$sub does not exist, skipping" >&2
  fi
done
