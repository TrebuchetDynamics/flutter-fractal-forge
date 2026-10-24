# ACAD-02 pilot: proposed source and identity decisions

**Prepared 2026-10-18 · metadata only · owner decisions pending**

This brief narrows the retained ACAD-02 discovery run to six bibliographically checked records and the existing 12-identity CAT-QUALITY pilot. It is a decision aid, not a completed screen: six current-identity associations are proposed and unreviewed, six identities remain unmapped, and none of the source, identity, inclusion, acquisition, or mathematical-claim fields has been approved. The machine-readable package binds each record to its retained `paper_id` and pilot result row, and each identity to the exact pilot ID/source label. Original run/queue/alias byte hashes and a scoped inventory fingerprint are recorded there; the raw run and empty reviewed-alias file are unchanged. The fingerprint covers the complete pilot section and its selected inventory rows, so unrelated catalog additions do not invalidate the package; any change to those selected inputs still requires review. Historical whole-inventory hashes and revisions remain in the companion. Since preparation, non-pilot entries were added while the selected pilot and all 12 identity rows stayed unchanged. The metadata observations retain their original 2026-10-18 retrieval date; this reconciliation did not perform another search or acquire content.

## Shortlist for owner consideration

| Retained paper | Bibliographic check and source/rights evidence | Proposed use and limits |
|---|---|---|
| `paper-c797646dae2767ea525a` — *Enhancing Computational Thinking…Root-finding using Newton Method and Creation of Newton Fractals* (2012) | Crossref DOI metadata confirms four authors, *International Journal of Computer Applications* 55(14), 9–15, online 2012-10-20. DOI: [10.5120/8821-2742](https://doi.org/10.5120/8821-2742). Crossref supplied no license; access/reuse rights are unknown. | Strong title-level lead for `core.newton_z3`; exact cubic, equations, and implementation match are not verified. Owner may decide whether to include and pursue lawful access. |
| `paper-7e5f945cdd5c68bdc9ec` — *Computational Discovery with Newton Fractals, Bohemian Matrices, & Mandelbrot Polynomials* (2021) | arXiv metadata confirms Calkin, Chan, and Corless; v1 submitted 2021-09-08; related DOI 10.1137/1.9781611977509. [Exact v1 record](https://arxiv.org/abs/2109.03765v1). The arXiv page displays CC BY-NC-SA 4.0; commercial reuse is not implied. | Broad metadata lead proposed for `core.mandelbrot`; title also names Newton fractals, but it does not establish the current quadratic formula/shader. |
| `paper-7d8c6ee70e9aac109422` — *New relatives of the Sierpinski gasket* (2018) | arXiv metadata confirms Bandt and Mekhontsev; v1 submitted 2018-01-25; journal reference *Chaos* 28(6), 063104 (2018). [Exact v1 record](https://arxiv.org/abs/1801.08325v1). The page identifies an arXiv non-exclusive distribution license, not a general reuse license. | Proposed for `core.sierpinski_triangle`; related gasket constructions do not establish the exact canonical triangle or app implementation. |
| `paper-9806495c34ee36881d38` — *Lyapunov dimension formula for the global attractor of the Lorenz system* (2016) | Crossref confirms Leonov, Kuznetsov, Korzhemanova, and Kusakin; *Communications in Nonlinear Science and Numerical Simulation* 41, 84–103, December 2016. [DOI](https://doi.org/10.1016/j.cnsns.2016.04.032). Crossref lists Elsevier TDM terms only; that is not treated as general reuse/acquisition permission. | Proposed for `core.lorenz_2d` at family level only. A global Lorenz attractor paper may not match the app's projected variant or parameters. |
| `paper-7ecdeae2ea0585a3c4ab` — *The Mandelbulb: first ‘true’ 3D image of famous fractal* (2009) | Crossref confirms Jacob Aron, *New Scientist* 204(2736), p. 54, November 2009. [DOI](https://doi.org/10.1016/s0262-4079(09)63150-x). Crossref lists Elsevier TDM terms only. | Proposed for `core.mandelbulb` as supplementary attribution/discovery context only; this is a popular-science magazine item, not a peer-reviewed mathematical authority or evidence for the renderer's formula. |
| `paper-7ed9dce0b5117c4a1add` — *Linear Cellular Automata, Substitutions, Hierarchical Iterated Function Systems and Attractors* (1992) | Crossref confirms v. Haeseler, Peitgen, and Skordev; Springer Berlin Heidelberg book chapter, pp. 3–23 (1992). [DOI](https://doi.org/10.1007/978-3-642-95678-2_1). Crossref lists Springer TDM terms only; no open reuse license was verified. | Broad IFS lead tentatively proposed for `core.barnsley_fern`; not specific evidence for Barnsley's affine maps. Hold for relevance and rights decisions. |

The metadata observation URLs, retrieval date, exact-version evidence, retained pilot references, and distinct pending decision fields are in [`ACAD-02-pilot-approval.json`](ACAD-02-pilot-approval.json). Bibliographic facts above come from public DOI/Crossref or arXiv metadata/landing pages. No article HTML, PDF, OCR, or article content was acquired or reviewed. “CC BY-NC-SA” and repository/TDM metadata are reported as evidence, not as an owner acquisition decision.

## Identity proposals and explicit gaps

Proposed, unreviewed mappings are: Mandelbrot → broad Mandelbrot-polynomial lead; Newton z³ → direct Newton-fractal title; Sierpinski triangle → related gasket paper; Barnsley fern → general IFS chapter; Lorenz 2D → Lorenz global-attractor paper; Mandelbulb → magazine context only. These retain the existing CAT pilot labels and state their ambiguity; a proposed association is not an alias approval.

No paper is mapped to Koch snowflake, Penrose tiling, Hénon, Thomas attractor, four-wing attractor, or Brian's Brain. The records with Hénon/cellular-automaton keywords are not sufficiently specific to justify identity matches. Those are gaps, not exclusions or negative mathematical findings. Number Walls is not one of the 12 actual pilot identities and remains accepted-planned, not implemented.

## Decisions requested / gates retained

1. Review each proposed identity-to-paper association or leave it unresolved; the repository's reviewed alias file remains empty until a separate attributable review.
2. For each source, decide screening separately from identity matching. Decide whether any lawful access request is warranted only after rights/access review. TDM terms, unknown rights, and arXiv distribution terms are not treated as blanket permission.
3. Keep screening, acquisition, extraction, source-check, implementation-comparison, and accepted-claim fields pending/unreviewed. No paper is marked included, acquired, or mathematically accepted.

ACAD-03 remains human-gated. This metadata package neither acquires full text nor accepts equations/claims. Validate it offline with:

```sh
python3 -m scripts.research.academic.review_package --repo-root .
```
