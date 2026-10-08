# qc_metrics

Per-sample read accounting and provenance.

- **Grain:** one row per sample
- **Primary key:** sample_key
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key

| Column | Type | Nullable | Description | Identifier Namespace | Units | Coordinate System | Null Meaning | Enum |
|---|---|---|---|---|---|---|---|---|
| sample_key | string | Yes | The id the registration published the sample under: a readset id (RS.…) for new registrations, the md5 sample_id for cmgd_nextflow 2.2.1. |  |  |  |  |  |
| sample_id | string | Yes | md5 of the sorted run accessions (NULL for readset-keyed registrations). |  |  |  |  |  |
| readset_id | string | Yes | Readset id (RS.…, ADR-0007) once known. |  |  |  |  |  |
| study_name | string | Yes | curatedMetagenomicData study name. |  |  |  |  |  |
| run_ids | string | Yes | Semicolon-separated SRA run accessions. |  |  |  |  |  |
| workflow_id | string | Yes | Registration workflow id. |  |  |  |  |  |
| version | string | Yes | Registration version. |  |  |  |  |  |
| reads_raw | int64 | Yes | Reads before host decontamination. |  | reads |  |  |  |
| reads_decontaminated | int64 | Yes | Reads after host decontamination. |  | reads |  |  |  |
| bases_raw | int64 | Yes | Bases before host decontamination. |  | bases |  |  |  |
| bases_decontaminated | int64 | Yes | Bases after host decontamination. |  | bases |  |  |  |
| reads_surviving_fraction | double | Yes | reads_decontaminated / reads_raw. |  | fraction (0-1) |  |  |  |
| bases_surviving_fraction | double | Yes | bases_decontaminated / bases_raw. |  | fraction (0-1) |  |  |  |
| metaphlan_index | string | Yes | MetaPhlAn index (2.2.x manifests). |  |  |  |  |  |
| metaphlan_profile | string | Yes | MetaPhlAn pass (release + index) the row comes from. |  |  |  |  |  |
| humann_bundle | string | Yes | HUMAnN bundle; NULL for rows outside a HUMAnN bundle. |  |  |  |  |  |
| pipeline_version | string | Yes | curatedMetagenomicsNextflow version that produced the sample. |  |  |  |  |  |
| git_commit | string | Yes | Pipeline git commit. |  |  |  |  |  |
