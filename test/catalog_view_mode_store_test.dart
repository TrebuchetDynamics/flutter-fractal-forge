import 'package:flutter_fractals/features/catalog/catalog_view_mode_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesCatalogViewModeStore', () {
    const store = SharedPreferencesCatalogViewModeStore();

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to grid mode when the preference is absent', () async {
      expect(await store.load(), CatalogViewMode.grid);
    });

    test('persists and reloads list mode', () async {
      await store.save(CatalogViewMode.list);

      expect(await store.load(), CatalogViewMode.list);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences
            .getBool(SharedPreferencesCatalogViewModeStore.preferenceKey),
        isFalse,
      );
    });
  });
}
