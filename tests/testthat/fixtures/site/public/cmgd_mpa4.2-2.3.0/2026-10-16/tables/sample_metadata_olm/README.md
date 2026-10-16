# sample_metadata_olm

Sample metadata from the Olm lab Microbiome Repo (pinned release), one row per field, with Olm's route and confidence; no evidence quotes. Attribution required: Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables.

- **Grain:** one row per sample, field and Olm sample
- **Primary key:** sample_key, field, source_sample
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC-BY-4.0
- **Sort by:** study_name, sample_key, field

| Column | Type | Nullable | Description | Identifier Namespace | Units | Coordinate System | Null Meaning | Enum |
|---|---|---|---|---|---|---|---|---|
| study_name | string | Yes | curatedMetagenomicData study name. |  |  |  |  |  |
| sample_key | string | Yes | The id the registration published the sample under: a readset id (RS.…) for new registrations, the md5 sample_id for cmgd_nextflow 2.2.1. |  |  |  |  |  |
| field | string | Yes | Metadata field: the harmonized name (age_years, sex, country, bmi, antibiotics_current_use, health_condition) where mapped, else the source's own. |  |  |  |  |  |
| value | string | Yes | Marker abundance as reported by MetaPhlAn. |  |  |  |  |  |
| source_field | string | Yes | The field name as the source spells it. |  |  |  |  |  |
| value_raw | string | Yes | The value exactly as the source gives it. |  |  |  |  |  |
| value_unit | string | Yes | The source's unit for value_raw, when it gives one. |  |  |  |  |  |
| confidence | double | Yes | Source-reported confidence (Olm routes R3/R4); NULL for curated values. |  | 0-1 |  |  |  |
| route | string | Yes | How the value was determined: 'curated' (cMD) or Olm's route R1-R4. |  |  |  |  |  |
| evidence_source | string | Yes | Olm evidence source (external.cmd = imported from cMD). |  |  |  |  |  |
| determined_by | string | Yes | Olm determination method. |  |  |  |  |  |
| biosample | string | Yes | INSDC BioSample accession(s), semicolon-separated (NULL if not yet known). |  |  |  |  |  |
| source | string | Yes | Metadata source: cmd (curatedMetagenomicData curation) or olm (Microbiome Repo). |  |  |  |  |  |
| release | string | Yes | Source release: cMD curation commit, or Olm release id. |  |  |  |  |  |
| source_sample | string | Yes | The source's own sample id (cMD sample_id, Olm sample_key). |  |  |  |  |  |
