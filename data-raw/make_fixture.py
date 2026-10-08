"""Publish the nextflow_telemetry fixture releases into OUT (see make_fixture.sh).

Run with the nextflow_telemetry environment, from that checkout's root:
    uv run python <cmgdr>/data-raw/make_fixture.py <OUT>

OUT/public is the cmgd-public store, OUT/raw stands in for cmgd-raw.
"""
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, "tests")
import cmgd_release_fixture as fx  # noqa: E402
from nextflow_telemetry.etl import publish  # noqa: E402

RAW_BASE = "https://cmgd-raw.cancerdatasci.org"

out = Path(sys.argv[1])
for row in fx._rows(*fx.HUMANN)["humann_genefamilies_files"]:
    dest = out / "raw" / row["key"]
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(fx.GF_FILE)
with tempfile.TemporaryDirectory() as lake_dir:
    con = fx.build_lake(Path(lake_dir))
    for reg in (fx.LEGACY, fx.HUMANN):
        publish.publish(con, *reg, out / "public", raw_base_url=RAW_BASE, today=fx.RELEASE_DAY)
    con.close()
