# metadata_sources

The metadata source releases in the store; `pinned` marks the one the metadata tables read.

- **Grain:** one row per source release
- **Primary key:** source, release
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0

| Column | Type | Nullable | Description | Identifier Namespace | Units | Coordinate System | Null Meaning | Enum |
|---|---|---|---|---|---|---|---|---|
| source | string | Yes | Metadata source: cmd (curatedMetagenomicData curation) or olm (Microbiome Repo). |  |  |  |  |  |
| release | string | Yes | Source release: cMD curation commit, or Olm release id. |  |  |  |  |  |
| package_version | string | Yes | Source data package version. |  |  |  |  |  |
| doi | string | Yes | Source release DOI. |  |  |  |  |  |
| license | string | Yes | Source licence. |  |  |  |  |  |
| sha256 | string | Yes | sha256 of the loaded source file. (Its download URL is in provenance.json: a frozen catalog may not carry URLs.) |  |  |  |  |  |
| loaded_at | string | Yes | When the release was loaded into the lake (UTC). |  |  |  |  |  |
| pinned | bool | Yes | Whether this is the release the metadata tables read. |  |  |  |  |  |
