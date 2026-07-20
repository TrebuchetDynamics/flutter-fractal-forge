# Research not needed

The reported module `legalize_auto_julibrotz_new` was one of the Legalize/XMission entries removed from the live registry by commit `c1cf90b8` because the shared shader approximated distinct Fractint formulas and produced incorrect previews.

Local evidence:
- `lib/core/modules/module_registry.dart` intentionally omits `buildSharedLegalizeFotdCatalogModules()` and documents that these entries require exact formula ports before re-enablement.
- `test/modules/legalize_fotd_shared_catalog_test.dart` checks every retained Legalize source entry, including `legalize_auto_julibrotz_new`, is absent from `ModuleRegistry`.
- The focused registry test passes, so the wrong-fractal and randomization paths reported here are no longer user-reachable.
