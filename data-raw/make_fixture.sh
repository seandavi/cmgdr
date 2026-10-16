#!/usr/bin/env bash
# Regenerate tests/testthat/fixtures/site, the fixture releases cmgdr's tests
# run against. The fixture is the contract between cmgdr and the publisher:
# regenerate it whenever the release layout changes.
#
# It is built by the publisher's own test fixture (tests/cmgd_release_fixture.py
# in seandavi/nextflow_telemetry) and `nf-etl publish`, so it has exactly the
# layout the publisher writes. Generated from nextflow_telemetry commit
# 23ddd65559797f874824eaa1c117e0bac44a81a8 (branch feat/230-publication, PR #235).
#
# The sample-metadata tables (cmgd_sample_metadata()) are not in the
# publisher's test fixture, so a 2-study slice of the real cmgd_mpa4.2-2.3.0
# release 2026-10-16 is added by make_metadata_fixture.py.
#
# Usage: data-raw/make_fixture.sh <nextflow_telemetry checkout> <published cmgd_mpa4.2-2.3.0 dir>
# (a local copy of https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/
# with latest.json, releases.json and 2026-10-16/)
set -euo pipefail

NFT=$(cd "${1:?usage: $0 <nextflow_telemetry checkout>}" && pwd)
MPA=$(cd "${2:?usage: $0 <nextflow_telemetry checkout> <published cmgd_mpa4.2-2.3.0 dir>}" && pwd)
PKG=$(cd "$(dirname "$0")/.." && pwd)
OUT="$PKG/tests/testthat/fixtures/site"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "nextflow_telemetry commit: $(git -C "$NFT" rev-parse HEAD)"
(cd "$NFT" && uv run python "$PKG/data-raw/make_fixture.py" "$WORK/site")
(cd "$NFT" && uv run python "$PKG/data-raw/make_metadata_fixture.py" "$MPA" 2026-10-16 "$WORK/site/public")

# The DuckLake catalogs are ~1.3 MB of mostly empty pages; the tests gunzip them.
find "$WORK/site" -name catalog.ducklake -exec gzip -9n {} \;

rm -rf "$OUT"
mkdir -p "$(dirname "$OUT")"
cp -r "$WORK/site" "$OUT"
du -sh "$OUT"
