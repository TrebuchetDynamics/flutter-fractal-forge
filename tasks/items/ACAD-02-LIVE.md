+++
schema = 1
id = "ACAD-02-LIVE"
title = "Live checks for ACAD-02"
short = "Live checks for ACAD-02"
status = "open"
goal = "ACAD-001"
section = "Next"
rank = 2000
depends_on = ["ACAD-02"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for ACAD-02 left pending."
acceptance = ["Each check passes on the real target: - Network pilot searches were not rerun during this retry; historical pilot artifacts are preserved. Retry arXiv failures when provider availability/rate limits permit; failures are not zero-hit evidence. - Human relevance, version/license review and any lawful acquisition approval for 906 pending records; no include/exclude decision or full-text acquisition was made."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#academic-research-library); `todo.archive.md` retains the original offline task and evidence.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: per-source human relevance/version/rights decisions; no full-text approval yet
- Owner decision: 2026-10-25: Delegated by user to assistant. Select the existing six-paper shortlist as the first review workload, not all 906 records. No new search or acquisition; preserve provider failures. Decision resolved; remaining input: per-source human relevance/version/rights decisions; no full-text approval yet. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until per-source human relevance/version/rights decisions; no full-text approval yet. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
