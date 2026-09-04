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
import os, re, subprocess, sys

manifest_path, dest = sys.argv[1], sys.argv[2]
text = open(manifest_path, encoding="utf-8").read()
blocks = re.split(r"\n\s*-\s+name:\s*", "\n" + text)
names = [block.strip().splitlines()[0].strip() for block in blocks[1:] if block.strip()]

for name in names:
    path = os.path.join(dest, name)
    if not os.path.isdir(path):
        print(f"skip missing: {name}")
        continue
    pkg = os.path.join(path, "package.json")
    req = os.path.join(path, "requirements.txt")
    pyproject = os.path.join(path, "pyproject.toml")
    if os.path.isfile(pkg):
        print(f"npm install: {name}")
        subprocess.check_call(["npm", "install"], cwd=path)
    elif os.path.isfile(pyproject):
        print(f"pip install: {name}")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--break-system-packages", "-e", path]
        )
    elif os.path.isfile(req):
        print(f"pip install: {name}")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--break-system-packages", "-r", req]
        )
    else:
        print(f"no known install file: {name}")
PY
