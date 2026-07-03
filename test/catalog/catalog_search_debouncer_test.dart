import 'package:flutter_fractals/features/catalog/data/catalog_search_debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogSearchDebouncer', () {
    test('only fires the latest scheduled callback', () async {
      final fired = <String>[];
      final debouncer = CatalogSearchDebouncer(
        delay: const Duration(milliseconds: 20),
      );
      addTearDown(debouncer.dispose);

      debouncer.schedule(() => fired.add('first'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      debouncer.schedule(() => fired.add('second'));

      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(fired, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fired, ['second']);
    });

    test('cancel drops a pending callback', () async {
      var fired = false;
      final debouncer = CatalogSearchDebouncer(
        delay: const Duration(milliseconds: 20),
      );
      addTearDown(debouncer.dispose);

      debouncer.schedule(() => fired = true);
      debouncer.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(fired, isFalse);
    });
  });
}
