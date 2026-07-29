import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Flutter's textContrastGuideline enforces the AA floor of 4.5, so the AAA
  // goal stated in UI_GUIDELINES.md needs its own check. These are pure colour
  // arithmetic — no widget tree, so they hold regardless of how a screen is
  // composed.
  group('accent text contrast', () {
    const aa = 4.5;
    const aaa = 7.0;

    test('dark theme accent clears AAA on both surfaces', () {
      expect(
        contrastRatio(AppColors.primaryLight, AppColors.surface),
        greaterThanOrEqualTo(aaa),
      );
      expect(
        contrastRatio(AppColors.primaryLight, AppColors.surfaceVariant),
        greaterThanOrEqualTo(aaa),
      );
    });

    test('oled theme accent clears AAA on both surfaces', () {
      expect(
        contrastRatio(OledColors.primaryLight, OledColors.surface),
        greaterThanOrEqualTo(aaa),
      );
      expect(
        contrastRatio(OledColors.primaryLight, OledColors.surfaceVariant),
        greaterThanOrEqualTo(aaa),
      );
    });

    test('high contrast theme accent clears AAA on both surfaces', () {
      expect(
        contrastRatio(
            HighContrastColors.primaryLight, HighContrastColors.surface),
        greaterThanOrEqualTo(aaa),
      );
      expect(
        contrastRatio(HighContrastColors.primaryLight,
            HighContrastColors.surfaceVariant),
        greaterThanOrEqualTo(aaa),
      );
    });

    test('body text tokens clear AAA', () {
      for (final surface in const [
        AppColors.surface,
        AppColors.surfaceVariant,
      ]) {
        expect(contrastRatio(AppColors.textPrimary, surface),
            greaterThanOrEqualTo(aaa));
        expect(contrastRatio(AppColors.textSecondary, surface),
            greaterThanOrEqualTo(aaa));
      }
    });

    test('primary is not used for text: it fails AA on a bare surface', () {
      // Documents why primaryLight exists. If this ever starts passing, the
      // surfaces changed and primaryLight may no longer need to be separate.
      expect(
        contrastRatio(AppColors.primary, AppColors.surface),
        lessThan(aa),
      );
    });

    test('textMuted is icon-only: clears 3:1 but not AA', () {
      final ratio = contrastRatio(AppColors.textMuted, AppColors.surfaceVariant);
      expect(ratio, greaterThanOrEqualTo(3.0));
      expect(ratio, lessThan(aa));
    });
  });
}
