import 'package:flutter_fractals/shared/utils/slugify.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Verbatim copies of the three original slug functions, used as oracles. ---
// These captured the pre-refactor behavior. The unified slugify() must match
// them for every input below, which proves the refactor is behavior-preserving.

String? originalExportSanitize(String value, {required String? fallback}) {
  final sanitized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_\-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^[_\-.]+|[_\-.]+$'), '');
  if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
    return fallback;
  }
  return sanitized;
}

String originalBatchSlug(String input) {
  final trimmed = input.trim().toLowerCase();
  final replaced = trimmed
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_'), '')
      .replaceAll(RegExp(r'_$'), '');
  return replaced.isEmpty ? 'untitled' : replaced;
}

String originalKeySegment(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

// Adversarial input matrix covering the edge cases the three functions differ
// on: emptiness, whitespace, hyphens, dots, leading/trailing separators,
// repeated separators, dot-segments, unicode, casing, and clean inputs.
const inputs = <String>[
  '',
  ' ',
  '   ',
  '\t\n',
  '.',
  '..',
  '...',
  'a',
  'A',
  'Hello',
  'Hello World',
  '  Hello  World  ',
  'my-export',
  'my-export-',
  '-my-export-',
  '--double--hyphen--',
  'a.b.c',
  '.hidden',
  'trailing.',
  'a__b',
  '___',
  '_-._-.',
  'file name (1).png',
  'Mandelbrot Set #3',
  'Seahorse Valley!!!',
  'café_münchen',
  'πr2',
  '123',
  '0',
  'already_clean_slug',
  'UPPER_AND-lower.99',
  'a   b   c',
  'mixed_-_separators',
  'end_',
  '_start',
  'a-_-b',
];

void main() {
  group('slugify matches the original export _sanitizeSegment', () {
    for (final fb in <String?>['fractal', null, '']) {
      test('fallback=$fb', () {
        for (final input in inputs) {
          expect(
            slugify(input, allowHyphen: true, emptyFallback: fb),
            originalExportSanitize(input, fallback: fb),
            reason: 'input: "$input", fallback: $fb',
          );
        }
      });
    }
  });

  test('slugify matches the original batch _safeBatchExportSlug', () {
    for (final input in inputs) {
      expect(
        slugify(input, allowHyphen: false, emptyFallback: 'untitled'),
        originalBatchSlug(input),
        reason: 'input: "$input"',
      );
    }
  });

  test('slugify matches the original catalog _keySegment', () {
    for (final input in inputs) {
      expect(
        slugify(input, allowHyphen: false, emptyFallback: ''),
        originalKeySegment(input),
        reason: 'input: "$input"',
      );
    }
  });
}
