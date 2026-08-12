import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
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
        contrastRatio(
            HighContrastColors.primaryLight, HighContrastColors.surfaceVariant),
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
      final ratio =
          contrastRatio(AppColors.textMuted, AppColors.surfaceVariant);
      expect(ratio, greaterThanOrEqualTo(3.0));
      expect(ratio, lessThan(aa));
    });
  });

  // The status colours are light enough that the theme's snack bar text is
  // unreadable on them, and textContrastGuideline never reaches a floating
  // snack bar to say so. These lock both halves: the colours themselves, and
  // the rule that call sites go through the helper that pairs them correctly.
  group('status-colour feedback', () {
    const aa = 4.5;

    test('the theme text colour fails on both status backgrounds', () {
      // Documents why appFeedbackSnackBar overrides the foreground at all.
      // If these start passing, the helper's override can go.
      expect(contrastRatio(AppColors.textPrimary, AppColors.success),
          lessThan(aa));
      expect(
          contrastRatio(AppColors.textPrimary, AppColors.error), lessThan(aa));
    });

    test('the helper foreground clears AA on both', () {
      expect(contrastRatio(AppColors.background, AppColors.success),
          greaterThanOrEqualTo(aa));
      expect(contrastRatio(AppColors.background, AppColors.error),
          greaterThanOrEqualTo(aa));
    });

    test('white on error fails, which is the FilledButton default', () {
      // destructiveFilledButtonStyle exists for this: a bare
      // FilledButton.styleFrom(backgroundColor: error) keeps white.
      expect(contrastRatio(Colors.white, AppColors.error), lessThan(aa));
    });

    test('snack bars that keep the theme background are already fine', () {
      expect(contrastRatio(AppColors.textPrimary, AppColors.surfaceElevated),
          greaterThanOrEqualTo(aa));
    });
  });

  // A source scan, because the defect is a pairing: a status background with
  // the theme's foreground. Nothing in a widget test catches it — the six
  // snack bars and two destructive buttons this replaced all rendered fine and
  // read at 2.55:1 to 3.49:1.
  group('status colours are only paired inside the helper', () {
    final helper = File('lib/shared/widgets/app_feedback_snack_bar.dart');

    test('no call site sets a status colour as a background itself', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path == helper.path) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('backgroundColor:') &&
              (line.contains('AppColors.error') ||
                  line.contains('AppColors.success'))) {
            offenders.add('${entity.path}:${i + 1}');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'use appFeedbackSnackBar or destructiveFilledButtonStyle so '
            'the foreground is paired with the background: $offenders',
      );
    });
  });
}
