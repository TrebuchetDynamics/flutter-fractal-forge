# ACAD-02 reproducible metadata pilot

## Method and limits

Bounded 20-query batch across six families, `rforge v0.1.20-2-g679bc9d`, sources openalex, arxiv, crossref, limit 25/query/source, continue-on-error. Native queries, manifest, raw data, failures, deduplicated records, statistics and screening queue are retained. No full text fetched.

## Bottom line

The run returned 956 records and 879 deduplicated records; stats report 831 unique DOI values. OpenAlex and Crossref returned hits; all 20 arXiv query attempts failed (mostly HTTP 429; one timeout and one 503). This is a retrieval pilot, not exhaustive/balanced coverage.

## Counts, reuse and screening

Source references (records may be counted twice): `{"crossref": 493, "openalex": 463}`. Existing corpus overlap: 154 deduplicated records share DOI/arXiv IDs with historical research packages; that is reuse, not new discovery. ACAD-01 import now validates 6,847 indexed sources. CAT-QUALITY-01 selected IDs were not found, so none were selected/promoted. Native queue contains 906 pending records. Relevant/excluded/uncertain counts: not assessed (no title-based screening); failed sources are not zero-hit evidence. The enriched `owner-review.csv` gives shared paper IDs when resolvable, source URL, declared license or unknown, version-verification request, pending decision and acquisition action.

## Access and next steps

All records are metadata-only. OpenAlex access flags are not license grants; owners must review version, source and rights before any lawful acquisition request. Number Walls remains a separate planned dossier, not an implemented renderer. No inclusion/exclusion or acquisition approvals were made.
