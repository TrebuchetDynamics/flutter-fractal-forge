+++
schema = 1
id = "RUST-M0-CONTRACTS"
title = "Freeze generated Dart catalog and shader interface inventories"
short = "Generate deterministic baseline v1 from real registry and catalog descriptors."
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 2000
depends_on = []
touches = ["test/migration/baseline_contracts_test.dart", "test/migration/support/baseline_inventory.dart", "migration/baseline/modules.json", "migration/baseline/parameters.json", "migration/baseline/presets.json", "migration/baseline/capabilities.json", "migration/baseline/shader-contracts.json", "docs/planning/refactor-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Implement a read-only default Flutter test exporter. Opt-in MIGRATION_BASELINE_OUT writes to an explicit scratch directory; explicit promotion creates modules.json, parameters.json, presets.json, capabilities.json and shader-contracts.json in migration/baseline. Preserve registry order as data, stable module/catalog identities, core/performance/hidden/diagnostic classification, parameter types/options/defaults, exact decimal strings, all built-in presets, actual CPU membership, precision capabilities and mathematical claim status. Resolve shader include declarations, float slots and sampler bindings with source hashes; unsupported introspection is explicitly unresolved, never a guessed layout. No uniform math or registry migration."
acceptance = ["Given the current registry and CatalogRepository, baseline_contracts_test.dart compares canonical output across two exports and fixtures; every descriptor is accounted for without fixed catalog counts, exact decimal/enum values survive, and output reads are side-effect free without the opt-in define.", "Given shader declarations, resolved includes and family constants, the same test detects an intentionally changed binding/asset/default/ID and preserves distinct sampler and float-slot records; unresolved custom ABI is reported with source path, not certified."]
checks = ["flutter test --no-pub test/migration/baseline_contracts_test.dart test/catalog/catalog_id_integrity_test.dart test/modules/escape_time_uniform_contract_test.dart test/modules/escape_time_shader_manifest_test.dart", "flutter test --no-pub test/migration/baseline_contracts_test.dart --dart-define=MIGRATION_BASELINE_OUT=/tmp/fractal-m0-contracts-a && flutter test --no-pub test/migration/baseline_contracts_test.dart --dart-define=MIGRATION_BASELINE_OUT=/tmp/fractal-m0-contracts-b && diff -r /tmp/fractal-m0-contracts-a /tmp/fractal-m0-contracts-b", "( export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\"; export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\"; export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\"; flutter --version && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No state/render replacement, ID renames, saved-data schema changes, publication or live device mutation in this offline task.", "Do not edit the seven pre-existing dirty test files; use isolated execution and preserve their work."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Planner call: canonical JSON schema=1; ordered identity field plus sorted serialization; provenance hashes outside deterministic payload. Reuse uniform_layout.dart, catalog repository and native CPU capability lookup, not README totals.
- Produces: migration/baseline/{modules,parameters,presets,capabilities,shader-contracts}.json, each versioned and bound to actual source hashes; inventory helper returns JSON-compatible records.
- Repo obligations triggered: spec.md Rendering interface and State and persistence remain unchanged; update the migration plan's M0 evidence only. Generated JSON and regression fixture are in touches; no production/CI/lock changes. Keep catalog_id_integrity_test.dart:45 and uniform contract:25-37 assertions unchanged; stale count comments are not a new baseline.
- Next action: add the proposed deterministic export/change-detection test; commands are unrun.
- Check setup: use private task-local equivalents of the named /tmp output paths in a worker; compare deterministic payloads, keeping host/time provenance separate. Both exports must come from unchanged inputs before promoting fixtures.
