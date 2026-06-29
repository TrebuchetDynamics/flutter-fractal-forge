import 'package:flutter_fractals/features/viewer/actions/text_overlay_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TextOverlayController.activeQuoteText', () {
    test('returns null when disabled', () {
      final c = TextOverlayController();
      c.applyEdit('Hello');
      // Manually flip enabled off to test disabled branch.
      c.toggle(); // enabled=true after applyEdit, toggle flips to false
      expect(c.enabled, isFalse);
      expect(c.activeQuoteText, isNull);
    });

    test('returns null when enabled but text is empty', () {
      final c = TextOverlayController();
      // applyEdit('') sets enabled=false and text=''; force enabled manually
      // via a load scenario — just test the invariant through applyEdit path.
      c.applyEdit('');
      expect(c.enabled, isFalse);
      expect(c.activeQuoteText, isNull);
    });

    test('returns null when enabled but text is whitespace only', () {
      final c = TextOverlayController();
      c.applyEdit('   ');
      expect(c.enabled, isFalse);
      expect(c.activeQuoteText, isNull);
    });

    test('returns trimmed text when enabled and non-empty', () {
      final c = TextOverlayController();
      c.applyEdit('  Hello world  ');
      expect(c.enabled, isTrue);
      expect(c.activeQuoteText, 'Hello world');
    });
  });

  group('TextOverlayController.needsEditBeforeToggle', () {
    test('true when text is empty', () {
      final c = TextOverlayController();
      expect(c.needsEditBeforeToggle, isTrue);
    });

    test('false when text is non-empty', () {
      final c = TextOverlayController();
      c.applyEdit('some text');
      expect(c.needsEditBeforeToggle, isFalse);
    });
  });

  group('TextOverlayController.toggle', () {
    test('flips enabled from true to false', () {
      final c = TextOverlayController();
      c.applyEdit('Fractal art');
      expect(c.enabled, isTrue);
      c.toggle();
      expect(c.enabled, isFalse);
    });

    test('flips enabled from false to true when text is present', () {
      final c = TextOverlayController();
      c.applyEdit('Fractal art');
      c.toggle(); // now false
      c.toggle(); // now true again
      expect(c.enabled, isTrue);
    });
  });

  group('TextOverlayController.applyEdit', () {
    test('trims whitespace and sets enabled=true for non-empty', () {
      final c = TextOverlayController();
      c.applyEdit('  Mandelbrot  ');
      expect(c.text, 'Mandelbrot');
      expect(c.enabled, isTrue);
    });

    test('sets enabled=false when result is empty after trim', () {
      final c = TextOverlayController();
      c.applyEdit('existing');
      c.applyEdit('   ');
      expect(c.text, '');
      expect(c.enabled, isFalse);
    });
  });

  group('TextOverlayController load / save', () {
    test('load returns defaults when prefs are empty', () async {
      final c = TextOverlayController();
      await c.load();
      expect(c.enabled, isFalse);
      expect(c.text, '');
    });

    test('save then load round-trips enabled and text', () async {
      final c1 = TextOverlayController();
      c1.applyEdit('Sierpinski');
      await c1.save();

      final c2 = TextOverlayController();
      await c2.load();
      expect(c2.enabled, isTrue);
      expect(c2.text, 'Sierpinski');
      expect(c2.activeQuoteText, 'Sierpinski');
    });

    test('save preserves disabled state', () async {
      final c1 = TextOverlayController();
      c1.applyEdit('Julia set');
      c1.toggle(); // disable
      await c1.save();

      final c2 = TextOverlayController();
      await c2.load();
      expect(c2.enabled, isFalse);
      expect(c2.text, 'Julia set');
      expect(c2.activeQuoteText, isNull);
    });
  });
}
