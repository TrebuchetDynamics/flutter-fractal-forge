# Research not needed

The reported module `legalize_auto_tman1` was one of the Legalize/XMission entries removed from the live registry by commit `c1cf90b8` because the shared shader approximated distinct Fractint formulas and exposed unsafe generic randomization ranges.

Local evidence:
- `lib/core/modules/module_registry.dart` intentionally omits `buildSharedLegalizeFotdCatalogModules()` and documents that these entries require exact formula ports before re-enablement.
- `test/modules/legalize_fotd_shared_catalog_test.dart` checks every retained Legalize source entry, including `legalize_auto_tman1`, is absent from `ModuleRegistry`.
- The focused registry test passes, so the broken-randomization path reported here is no longer user-reachable.
