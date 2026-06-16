import 'package:flutter/material.dart';

/// Shared text style for muted section labels in the option bottom sheets
/// (export, wallpaper): the theme's `titleSmall` tinted to 70% `onSurface`.
///
/// Centralizes a style block that was copy-pasted across those sheets so the
/// section headings stay visually consistent.
TextStyle? sheetSectionLabelStyle(ThemeData theme) =>
    theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
