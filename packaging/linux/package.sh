#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
DIST="$ROOT/dist/linux"

if [ ! -x "$BUNDLE/typing_academy_desktop" ]; then
  echo "Build the Linux release first:"
  echo "  flutter build linux --release"
  exit 1
fi

mkdir -p "$DIST"
cp -a "$BUNDLE/." "$DIST/"
chmod +x "$DIST/typing_academy_desktop"
echo "Linux bundle copied to $DIST"
echo "Run: $DIST/typing_academy_desktop"
