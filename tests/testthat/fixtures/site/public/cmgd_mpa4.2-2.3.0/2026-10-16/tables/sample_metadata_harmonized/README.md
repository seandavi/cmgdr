# sample_metadata_harmonized

One value per sample and harmonized field, with the source and source release it came from (precedence: cMD curation, then Olm R1/R2 not imported from cMD, then Olm R3/R4 with confidence >= 0.5). Mixes Olm-derived values; attribution required: Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables.

- **Grain:** one row per sample and field
- **Primary key:** sample_key, field
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
| source | string | Yes | Metadata source: cmd (curatedMetagenomicData curation) or olm (Microbiome Repo). |  |  |  |  |  |
| release | string | Yes | Source release: cMD curation commit, or Olm release id. |  |  |  |  |  |
| route | string | Yes | How the value was determined: 'curated' (cMD) or Olm's route R1-R4. |  |  |  |  |  |
| confidence | double | Yes | Source-reported confidence (Olm routes R3/R4); NULL for curated values. |  | 0-1 |  |  |  |
