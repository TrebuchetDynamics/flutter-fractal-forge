import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// A snack bar that reports whether an operation worked.
///
/// Exists because the status colours are far too light to carry the theme's
/// snack bar text. `snackBarTheme.contentTextStyle` is [AppTypography.bodyMedium],
/// whose colour is [AppColors.textPrimary]; against [AppColors.success] that is
/// 2.55:1 and against [AppColors.error] 3.2:1, both under the 4.5:1 floor for
/// body text. [AppColors.background] reads 7.09:1 and 5.66:1 against the same
/// two, so the foreground is set here rather than left to the theme.
///
/// Snack bars that do not override the background need none of this: the theme's
/// [AppColors.surfaceElevated] carries [AppColors.textPrimary] at 14.43:1.
///
/// Note that `textContrastGuideline` does not reach a floating snack bar, so
/// nothing catches a regression here automatically — assert the colour.
SnackBar appFeedbackSnackBar({
  required String message,
  required bool success,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  return SnackBar(
    content: Text(
      message,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.background),
    ),
    backgroundColor: success ? AppColors.success : AppColors.error,
    behavior: behavior,
  );
}

/// Foreground for a filled button that uses [AppColors.error] as its fill.
///
/// FilledButton's default foreground on a custom fill is white, which is 3.49:1
/// on [AppColors.error] — under the floor, on the destructive confirmation
/// buttons where the label matters most. [AppColors.background] reads 5.66:1.
ButtonStyle destructiveFilledButtonStyle() => FilledButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.background,
    );
