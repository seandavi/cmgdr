"""Slice the published sample-metadata tables of a real release (see make_fixture.sh).

    python make_metadata_fixture.py <published dataset dir> <release> <OUT/public>

Copies, for STUDIES only, the `samples` table and the sample-metadata tables
(all of `metadata_sources`) with their schema.json and README.md, rewrites each
files.json for the sliced Parquet, and writes a manifest with just these tables
(row counts updated, licences kept). The DuckLake catalog is left out:
cmgd_sample_metadata() reads the Parquet files through files.json.
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

import duckdb

STUDIES = ("ZellerG_2014", "LassalleF_2017")  # LassalleF_2017 has no Olm metadata
TABLES = ("samples", "sample_metadata_harmonized", "sample_metadata_cmd",
          "sample_metadata_olm", "metadata_sources")

src_ds, release, public = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
src = src_ds / release
dst_ds = public / src_ds.name
dst = dst_ds / release
dst.mkdir(parents=True)
for f in ("latest.json", "releases.json"):
    shutil.copy(src_ds / f, dst_ds / f)

manifest = json.loads((src / "manifest.json").read_text())
manifest["tables"] = [t for t in manifest["tables"] if t["name"] in TABLES]
del manifest["artifacts"]["ducklake"]
con = duckdb.connect()
for t in manifest["tables"]:
    name = t["name"]
    tdir = dst / "tables" / name
    (tdir / "data").mkdir(parents=True)
    for f in ("schema.json", "README.md"):
        shutil.copy(src / "tables" / name / f, tdir / f)
    files = json.loads((src / t["files"]).read_text())
    where = "" if name == "metadata_sources" else f"WHERE study_name IN {STUDIES}"
    parquet = tdir / "data" / "part-00000.parquet"
    srcs = [str(src / "tables" / name / f["uri"]) for f in files["files"]]
    con.execute(f"COPY (SELECT * FROM read_parquet({srcs}) {where}) TO '{parquet}' (FORMAT parquet)")
    rows = con.execute(f"SELECT count(*) FROM '{parquet}'").fetchone()[0]
    data = parquet.read_bytes()
    files["files"] = [dict(files["files"][0], uri="data/part-00000.parquet", size=len(data),
                           sha256=hashlib.sha256(data).hexdigest(), rows=rows)]
    (tdir / "files.json").write_text(json.dumps(files, indent=2))
    t["row_count"] = rows
(dst / "manifest.json").write_text(json.dumps(manifest, indent=1))
