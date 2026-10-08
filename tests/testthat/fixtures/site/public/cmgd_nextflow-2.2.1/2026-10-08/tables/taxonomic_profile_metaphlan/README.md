# taxonomic_profile_metaphlan

MetaPhlAn taxonomic profiles: the main pass, plus a HUMAnN bundle's own pass (humann_bundle set).

- **Grain:** one row per sample, branch, MetaPhlAn pass and clade
- **Primary key:** sample_key, data_type, metaphlan_profile, humann_bundle, clade_name
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key, clade_name

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
| metaphlan_profile | string | Yes | MetaPhlAn pass (release + index) the row comes from. |  |  |  |  |  |
| humann_bundle | string | Yes | HUMAnN bundle; NULL for rows outside a HUMAnN bundle. |  |  |  |  |  |
| clade_name | string | Yes | Clade label exactly as the profiler reported it. |  |  |  |  |  |
| rank | string | Yes | Taxonomic rank (kingdom … species, strain). |  |  |  |  |  |
| ncbi_taxid | int32 | Yes | NCBI taxonomy id of the clade. |  |  |  |  |  |
| sgb_id | string | Yes | MetaPhlAn species-level genome bin (t__SGB…), on SGB leaves. |  |  |  |  |  |
| relative_abundance | double | Yes | MetaPhlAn relative abundance. |  | percent |  |  |  |
| coverage | double | Yes | Coverage as reported by the tool. |  |  |  |  |  |
| estimated_reads | int64 | Yes | Estimated reads assigned to the clade. |  | reads |  |  |  |
