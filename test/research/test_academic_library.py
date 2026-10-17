import json
from scripts.research.academic.library import find_title_collisions, import_run, validate_library


def test_import_deduplicates_doi_and_arxiv_aliases_without_merging_title_collisions(tmp_path):
    run = tmp_path / "run"
    run.mkdir()
    (run / "results.jsonl").write_text(
        "\n".join(
            json.dumps(row)
            for row in [
                {"title": "A Study", "doi": "https://doi.org/10.1234/ABC", "arxiv_id": "2401.00001v2", "authors": ["A"]},
                {"title": "A Study", "doi": "10.1234/abc", "arxiv": "2401.00001", "authors": ["A"]},
                {"title": "A Study", "doi": "10.1234/other", "authors": ["B"]},
                {"title": "A Study", "arxiv": "2401.00001", "authors": ["A"]},
            ]
        )
        + "\n"
    )
    output = tmp_path / "papers.jsonl"

    import_run(run, output)
    first = output.read_bytes()
    import_run(run, output)

    assert output.read_bytes() == first
    papers = [json.loads(line) for line in first.splitlines()]
    assert len(papers) == 3
    assert len({paper["paper_id"] for paper in papers}) == 3
    assert (run / "results.jsonl").exists()  # source run remains untouched
    collisions = find_title_collisions(papers)
    assert len(collisions) == 1
    assert len(collisions[0]["paper_ids"]) == 3
    assert collisions[0]["status"] == "review_pending"


def test_import_preserves_metadata_only_and_distinct_evidence_states(tmp_path):
    run = tmp_path / "run"
    run.mkdir()
    (run / "results.jsonl").write_text(json.dumps({"title": "Metadata", "url": "https://example.org/p"}) + "\n")
    output = tmp_path / "papers.jsonl"

    import_run(run, output)

    paper = json.loads(output.read_text())
    assert paper["content_state"] == "metadata_only"
    assert paper["claim_state"] == "unreviewed"


def test_import_classifies_code_and_video_as_supplementary_not_verified_claims(tmp_path):
    run = tmp_path / "run"
    run.mkdir()
    rows = [
        {"title": "Implementation", "source_kind": "code", "url": "https://example.org/code"},
        {"title": "Lecture", "source_kind": "video", "url": "https://example.org/video"},
    ]
    (run / "results.jsonl").write_text("".join(json.dumps(row) + "\n" for row in rows))
    output = tmp_path / "papers.jsonl"

    import_run(run, output)

    papers = [json.loads(line) for line in output.read_text().splitlines()]
    assert {paper["source_kind"] for paper in papers} == {"code", "video"}
    assert {paper["content_state"] for paper in papers} == {"metadata_only"}
    assert {paper["claim_state"] for paper in papers} == {"unreviewed"}


def test_validator_rejects_missing_sources_stale_bindings_unsupported_claims_and_public_files():
    library = {
        "schema_version": 1,
        "papers": [],
        "mappings": [
            {
                "identity": "core.demo",
                "source_ids": ["missing"],
                "claim_state": "numerically_checked",
                "implementation": {"path": "lib/demo.dart", "sha256": "sha256:" + "0" * 64},
                "observed_sha256": "sha256:" + "1" * 64,
                "claim_spans": [],
                "source_checked": False,
                "numerical_check": False,
            },
            {
                "identity": "core.public",
                "source_ids": [],
                "claim_state": "unreviewed",
                "public_files": ["research/academic/pdfs/paper.pdf"],
            },
        ],
    }

    errors = validate_library(library)

    assert any("missing source" in error for error in errors)
    assert any("stale implementation binding" in error for error in errors)
    assert any("unsupported claim upgrade" in error for error in errors)
    assert any("illegal public file" in error for error in errors)


def test_validator_rejects_rights_without_basis_and_claim_without_span():
    library = {
        "schema_version": 1,
        "papers": [{"paper_id": "p1", "title": "Paper", "rights": {"status": "full_text_available"}}],
        "mappings": [{
            "identity": "core.demo",
            "source_ids": ["p1"],
            "claim_state": "source_checked",
            "claim_spans": [],
            "source_checked": True,
        }],
    }

    errors = validate_library(library)

    assert any("rights" in error for error in errors)
    assert any("claim span" in error for error in errors)
