+++
schema = 1
id = "ACAD-DRAFT-01"
title = "Prepare bounded delegated academic review drafts without source acquisition"
short = "Draft six-source and 12-identity review packet"
status = "open"
goal = "ACAD-001"
section = "Now"
rank = 1000
depends_on = ["ACAD-007-f8"]
touches = ["research/academic/reviews/delegated-20261025/"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Implement the delegated draft-only preparation phase in research/academic/reviews/delegated-20261025/: create a machine-readable draft packet and concise review brief using the existing six-paper approval package, existing identity/collision records and current effective renderer source. Cover all 12 pilot identities with source/binding references and explicit gaps; produce per-record role/relevance/rights recommendations and collision/alias alternatives where evidenced. Prioritize Newton relevance, retain other five limitations and six unmapped identities. No new search, full text, PDF/OCR, provider setup, reviewed-alias changes or human-accepted claims."
acceptance = ["Exactly the six existing paper IDs and 12 pilot identity IDs reconcile to the immutable preparation package; each dossier binds current implementation paths and flags source/equation gaps honestly. Draft actors are explicitly agents; human identity, inclusion, acquisition, extraction and claim approval fields remain pending. No fabricated source spans or numerical oracle.", "Record original pilot/package/alias hashes and prove unchanged. Deliver JSON plus Markdown with per-source recommendation, rights gap, proposed mapping status and exact next human input; no blanket approval of the 906 records."]
checks = ["Run /usr/bin/python3 -m scripts.research.academic.review_package --repo-root .; run the existing focused test/research/test_academic_review_package.py suite using the provisioned interpreter. Validate JSON ID sets/counts, draft/pending decision invariants, current referenced files and preserved input hashes; git diff --check."]
exclusions = ["No acquisition, new network search, source licensing conclusion, reviewed alias edit, screening approval, accepted mathematical claim or publication. Do not modify the preparation snapshot or weaken its validator."]
+++
- Sources: docs/tasks/DELEGATED-DECISIONS-20261025.md#academic-draft-priorities
