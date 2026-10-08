# humann_pathabundance

HUMAnN pathway abundances, unnormalized, in the bundle's units.

- **Grain:** one row per sample, pathway and stratum (NULL = community total)
- **Primary key:** sample_key, humann_bundle, pathway, stratum
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key, pathway

| Column | Type | Nullable | Description | Identifier Namespace | Units | Coordinate System | Null Meaning | Enum |
|---|---|---|---|---|---|---|---|---|
| sample_key | string | Yes | The id the registration published the sample under: a readset id (RS.…) for new registrations, the md5 sample_id for cmgd_nextflow 2.2.1. |  |  |  |  |  |
| sample_id | string | Yes | md5 of the sorted run accessions (NULL for readset-keyed registrations). |  |  |  |  |  |
| readset_id | string | Yes | Readset id (RS.…, ADR-0007) once known. |  |  |  |  |  |
| study_name | string | Yes | curatedMetagenomicData study name. |  |  |  |  |  |
| run_ids | string | Yes | Semicolon-separated SRA run accessions. |  |  |  |  |  |
| workflow_id | string | Yes | Registration workflow id. |  |  |  |  |  |
| version | string | Yes | Registration version. |  |  |  |  |  |
| data_type | string | Yes | full_data (all reads) or rarefied_data (1M-read subsample). |  |  |  |  |  |
| humann_bundle | string | Yes | HUMAnN bundle; NULL for rows outside a HUMAnN bundle. |  |  |  |  |  |
| pathway | string | Yes | HUMAnN pathway (or UNMAPPED / UNINTEGRATED). |  |  |  |  |  |
| stratum | string | Yes | Contributing taxon; NULL for the community total. |  |  |  |  |  |
| abundance | double | Yes | HUMAnN abundance, unnormalized. |  | bundle units (3.9 RPK, 4.x CPM) |  |  |  |
