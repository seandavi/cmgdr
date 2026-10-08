# resistome

Antimicrobial-resistance genes (KMA against CARD).

- **Grain:** one row per sample, branch and CARD template
- **Primary key:** sample_key, data_type, gene
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key, gene

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
| gene | string | Yes | CARD reference template. |  |  |  |  |  |
| template_coverage | double | Yes | KMA template coverage. |  | percent |  |  |  |
| template_identity | double | Yes | KMA template identity. |  | percent |  |  |  |
| depth | double | Yes | KMA depth. |  |  |  |  |  |
| score | double | Yes | KMA score. |  |  |  |  |  |
