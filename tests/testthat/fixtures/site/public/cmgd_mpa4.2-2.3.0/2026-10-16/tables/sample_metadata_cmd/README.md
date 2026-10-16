# sample_metadata_cmd

Sample metadata curated by curatedMetagenomicData (curation repo, pinned commit), one row per field. `field`/`value` are harmonized where the field map covers the field.

- **Grain:** one row per sample, field and cMD sample record
- **Primary key:** sample_key, field, source_sample
- **Temporal model:** `upsert_latest_snapshot` — One mutable current row per natural key, updated only when tracked values change.
- **Owner:** curatedMetagenomicData
- **License:** CC0-1.0
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
| value_ontology | string | Yes | Ontology term ids the source attaches to the value. |  |  |  |  |  |
| curator | string | Yes | cMD curator of the record. |  |  |  |  |  |
| source | string | Yes | Metadata source: cmd (curatedMetagenomicData curation) or olm (Microbiome Repo). |  |  |  |  |  |
| release | string | Yes | Source release: cMD curation commit, or Olm release id. |  |  |  |  |  |
| source_sample | string | Yes | The source's own sample id (cMD sample_id, Olm sample_key). |  |  |  |  |  |
