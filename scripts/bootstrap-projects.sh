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
    url = ""
    for line in lines[1:]:
        m = re.match(r"\s*url:\s*(\S+)", line)
        if m:
            url = m.group(1)
    if not name or not url:
        raise SystemExit(f"invalid manifest entry:\n{block}")
    items.append((name, url))

os.makedirs(dest, exist_ok=True)
for name, url in items:
    path = os.path.join(dest, name)
    if os.path.isdir(os.path.join(path, ".git")):
        print(f"skip exists: {name}")
        continue
    if os.path.exists(path):
        raise SystemExit(f"path exists but is not a git repo: {path}")
    print(f"clone {url} -> projects/{name}")
    subprocess.check_call(["git", "clone", url, path])
PY
