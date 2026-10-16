# samples

One row per sample in the release: the join hub from readset id to run accessions, BioSample and BioProject, with the pipeline version that produced it.

- **Grain:** one row per sample
- **Primary key:** sample_key
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key

| Column | Type | Nullable | Description | Identifier Namespace | Units | Coordinate System | Null Meaning | Enum |
|---|---|---|---|---|---|---|---|---|
| study_name | string | Yes | curatedMetagenomicData study name. |  |  |  |  |  |
| sample_key | string | Yes | The id the registration published the sample under: a readset id (RS.…) for new registrations, the md5 sample_id for cmgd_nextflow 2.2.1. |  |  |  |  |  |
| readset_id | string | Yes | Readset id (RS.…, ADR-0007) once known. |  |  |  |  |  |
| run_accessions | string | Yes | Semicolon-separated INSDC run accessions of the readset. |  |  |  |  |  |
| biosample | string | Yes | INSDC BioSample accession(s), semicolon-separated (NULL if not yet known). |  |  |  |  |  |
| bioproject | string | Yes | INSDC BioProject/study accession(s), semicolon-separated. |  |  |  |  |  |
| pipeline_version | string | Yes | curatedMetagenomicsNextflow version that produced the sample. |  |  |  |  |  |
| git_commit | string | Yes | Pipeline git commit. |  |  |  |  |  |
| completed_at | string | Yes | When the pipeline run for this sample completed (UTC, ISO 8601). |  |  |  |  |  |
