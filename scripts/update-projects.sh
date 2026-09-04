#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/projects/manifest.yaml"
DEST="$ROOT/projects"

if [[ ! -f "$MANIFEST" ]]; then
  echo "missing manifest: $MANIFEST" >&2
  exit 1
fi

python3 - "$MANIFEST" "$DEST" <<'PY'
import sys, subprocess, os, re

manifest_path, dest = sys.argv[1], sys.argv[2]
text = open(manifest_path, encoding="utf-8").read()
blocks = re.split(r"\n\s*-\s+name:\s*", "\n" + text)
items = []
for block in blocks[1:]:
    lines = block.strip().splitlines()
    name = lines[0].strip()
    if name:
        items.append(name)

for name in items:
    path = os.path.join(dest, name)
    git_dir = os.path.join(path, ".git")
    if not os.path.isdir(git_dir):
        print(f"skip missing: {name}")
        continue
    print(f"update {name}")
    subprocess.check_call(["git", "-C", path, "pull", "--ff-only"])
PY
