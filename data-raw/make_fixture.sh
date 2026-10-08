#!/usr/bin/env bash
# Regenerate tests/testthat/fixtures/site, the fixture releases cmgdr's tests
# run against. The fixture is the contract between cmgdr and the publisher:
# regenerate it whenever the release layout changes.
#
# It is built by the publisher's own test fixture (tests/cmgd_release_fixture.py
# in seandavi/nextflow_telemetry) and `nf-etl publish`, so it has exactly the
# layout the publisher writes. Generated from nextflow_telemetry commit
# 23b76ee3d5d316119ec9706053e77d5ab4f2fe91 (branch feat/230-publication, PR #235).
#
# Usage: data-raw/make_fixture.sh <nextflow_telemetry checkout>
set -euo pipefail

NFT=$(cd "${1:?usage: $0 <nextflow_telemetry checkout>}" && pwd)
PKG=$(cd "$(dirname "$0")/.." && pwd)
OUT="$PKG/tests/testthat/fixtures/site"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "nextflow_telemetry commit: $(git -C "$NFT" rev-parse HEAD)"
(cd "$NFT" && uv run python "$PKG/data-raw/make_fixture.py" "$WORK/site")

# The DuckLake catalogs are ~1.3 MB of mostly empty pages; the tests gunzip them.
find "$WORK/site" -name catalog.ducklake -exec gzip -9n {} \;

rm -rf "$OUT"
mkdir -p "$(dirname "$OUT")"
cp -r "$WORK/site" "$OUT"
du -sh "$OUT"
