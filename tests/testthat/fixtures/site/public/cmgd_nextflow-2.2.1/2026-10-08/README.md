# curatedMetagenomicData: cmgd_nextflow 2.2.1

Profiles from the cmgd_nextflow 2.2.1 registration of curatedMetagenomicsNextflow, one full snapshot per release. HUMAnN gene families are per-sample downloads listed in genefamilies/index.json.

- **Publisher:** curatedMetagenomicData
- **Required artifacts:** ducklake, parquet

# marker_abundance

MetaPhlAn marker abundances.

- **Grain:** one row per sample, branch and marker
- **Primary key:** sample_key, data_type, marker_name
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key, marker_name

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
| marker_name | string | Yes | MetaPhlAn marker id. |  |  |  |  |  |
| value | double | Yes | Marker abundance as reported by MetaPhlAn. |  |  |  |  |  |

# marker_presence

MetaPhlAn markers present in a sample (a row exists iff the marker is present).

- **Grain:** one row per sample, branch and present marker
- **Primary key:** sample_key, data_type, marker_name
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
- **Sort by:** study_name, sample_key, marker_name

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
| marker_name | string | Yes | MetaPhlAn marker id. |  |  |  |  |  |

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

# taxonomic_profile_bracken

Kraken2/Bracken species and genus profiles.

- **Grain:** one row per sample, branch and taxon
- **Primary key:** sample_key, data_type, clade_name
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
| clade_name | string | Yes | Clade label exactly as the profiler reported it. |  |  |  |  |  |
| rank | string | Yes | Taxonomic rank (kingdom … species, strain). |  |  |  |  |  |
| ncbi_taxid | int32 | Yes | NCBI taxonomy id of the clade. |  |  |  |  |  |
| fraction_total_reads | double | Yes | Bracken fraction of total reads. |  | fraction (0-1) |  |  |  |
| estimated_reads | int64 | Yes | Estimated reads assigned to the clade. |  | reads |  |  |  |

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
