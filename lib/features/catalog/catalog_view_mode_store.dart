import 'package:shared_preferences/shared_preferences.dart';

enum CatalogViewMode { grid, list }

abstract interface class CatalogViewModeStore {
  Future<CatalogViewMode> load();

  Future<void> save(CatalogViewMode mode);
}

class SharedPreferencesCatalogViewModeStore implements CatalogViewModeStore {
  static const String preferenceKey = 'catalog_view_grid';

  const SharedPreferencesCatalogViewModeStore();

  @override
  Future<CatalogViewMode> load() async {
    final preferences = await SharedPreferences.getInstance();
    final showGrid = preferences.getBool(preferenceKey) ?? true;

    return showGrid ? CatalogViewMode.grid : CatalogViewMode.list;
  }

  @override
  Future<void> save(CatalogViewMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      preferenceKey,
      mode == CatalogViewMode.grid,
    );
  }
}
