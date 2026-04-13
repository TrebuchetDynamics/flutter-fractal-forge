# Fractal Forge — Future Work Parking Lot

**Status:** Non-binding. Items here are *deferred*, not rejected. They are out of scope for the current fractal research pipeline (see `2026-04-12-fractal-research-pipeline-design.md`) but are technically feasible and can be promoted to active specs when priorities allow.

**Purpose:** Capture ideas so the hard-limits section of active specs stays focused without losing the idea.

---

## 1. Runtime Shader Compilation

**What it is:** Load and compile fractal shaders (GLSL/SkSL) at app runtime instead of bundling them AOT. Users could pick a new fractal without reinstalling the app.

**Feasibility:** Possible now via Impeller GLSL path and `flutter_gpu_shaders`. Maturing fast as Impeller stabilizes across iOS / Android / desktop / web.

**Unblocks when:**
- Impeller GLSL runtime is stable on all target platforms
- A minimal sandboxed shader-loading API is available in Flutter stable
- We have > 1K implemented fractals (bundle size becomes a real concern)

**Scope estimate:** Medium. Mostly platform plumbing + security review of shader validation.

**Dependencies on current pipeline:**
- Reuses the same `metadata.yaml` + `.glsl` files; no schema changes needed
- Admission gates still apply (compile check + thumbnail render)

---

## 2. User-Generated Formula Uploads

**What it is:** Let users define new fractal formulas inside the app (or via a web form) and render them.

**Feasibility:** Fully possible, but not by accepting raw GLSL — that's a sandbox risk. Need a **safe DSL subset** (a restricted formula language that compiles to GLSL internally), plus moderation.

**Unblocks when:**
- Runtime shader compilation (item 1) is available
- A formula DSL is designed (escape-time + attractor + IFS subsets)
- Moderation & abuse pipeline exists (report, review, ban)

**Scope estimate:** Large. DSL design alone is a multi-week project; moderation is ongoing ops work.

**Dependencies on current pipeline:**
- User uploads become `research/extracted/` candidates and flow through the same admission gate
- Adds a new `source.type: user_upload` in the schema

---

## 3. Web Dashboard Backend

**What it is:** A live web dashboard for catalog health, search, and public browsing (vs the current static HTML in `reports/dashboard.html`).

**Feasibility:** Trivially possible. Static HTML covers 95% of internal needs; a backend is only justified for public search, auth, or write features.

**Unblocks when:**
- Public browsing becomes a goal (catalog as a web reference, not just an app feature)
- Static generation stops scaling (> ~20K entries or complex filtering needed)
- Community features (item 4) require auth

**Scope estimate:** Small to medium. Off-the-shelf: Cloudflare Pages + D1, or Supabase + Next.js. Registry stays the source of truth; backend is read-derived.

**Dependencies on current pipeline:**
- Backend reads from `fractal_registry.yaml` via a sync job; never writes to it
- No schema changes

---

## 4. Community Marketplace / Voting

**What it is:** Let users favorite, comment, rate, and share fractals. Optionally a marketplace for user-created presets or palettes.

**Feasibility:** Standard social product. Real work lies in moderation, spam, and reputation systems — not in the core tech.

**Unblocks when:**
- Web dashboard backend (item 3) exists
- User-generated uploads (item 2) exist OR user-created presets are allowed
- A moderation policy and ops capacity are in place
- User base is large enough to justify (> tens of thousands of users)

**Scope estimate:** Very large. This is a full social product surface.

**Dependencies on current pipeline:**
- None directly; lives in the app + backend layers
- Favorites/ratings could feed back as a quality signal in the registry (opt-in, low priority)

---

## 5. Automated Formula Generation (Assisted Discovery)

**What it is:** LLM or genetic algorithm proposes new fractal formulas that the pipeline then evaluates as normal candidates.

**Feasibility:** Partially possible today, experimental. LLMs can propose variations of known families; genetic algorithms have historically produced "evolved art" in this space. Quality bar is low — most generated formulas are visually uninteresting or mathematically degenerate.

**Unblocks when:**
- Growth from human-discovered sources plateaus (past ~5K entries, returns diminish)
- A visual-interest classifier exists (screen out boring outputs automatically)
- LLM cost / latency allows bulk proposal (Haiku-tier batch works today)

**Scope estimate:** Medium. Proposer is easy; the visual-interest filter is the real research problem.

**Dependencies on current pipeline:**
- Generated formulas enter as `source.type: generated` candidates
- **Same admission gates apply** — no special treatment, no lower bar
- Likely needs a higher rejection-rate tolerance in `dedup-rescan` reports (reframed as a signal, not a regression)

---

## Review cadence

This file is reviewed when:
- Phase 2 completes (~3,000 entries admitted)
- Flutter major version bump
- Any of these items gains an external driver (Impeller stable, user demand, etc.)

Moving an item from here to an active spec requires a full brainstorming pass — nothing is promoted by default.
