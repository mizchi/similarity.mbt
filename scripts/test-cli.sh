#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
binary="$root/similarity-mbt"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cat > "$work/a.mbt" <<'SOURCE'
fn add(a : Int, b : Int) -> Int {
  a + b
}
fn sum(x : Int, y : Int) -> Int {
  x + y
}
SOURCE
cat > "$work/b.mbt" <<'SOURCE'
fn plus(a : Int, b : Int) -> Int {
  a + b
}
SOURCE
cp "$work/b.mbt" "$work/ignored_test.mbt"
mkdir "$work/node_modules"
cp "$work/b.mbt" "$work/node_modules/ignored.mbt"
"$binary" --help | grep -F 'MoonBit code similarity detection'
"$binary" "$work/a.mbt" | grep -F '(100%)'
"$binary" --internal-worker "$work/a.mbt" "$work/b.mbt" 0.99 | grep -F '(100%)'
"$binary" -w 2 -t 0.99 "$work/a.mbt" "$work/b.mbt" | grep -F 'Matches: 2'
"$binary" --no-tests "$work/a.mbt" "$work/ignored_test.mbt" | grep -F '(100%)'
(cd "$work" && "$binary" --no-tests -w 2) | grep -F 'Files: 2'
echo 'Native CLI smoke tests passed.'
