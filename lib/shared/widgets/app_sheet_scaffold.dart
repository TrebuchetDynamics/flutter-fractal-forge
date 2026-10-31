import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

/// Header, divider and scrollable body shared by modal [AppBottomSheet] panels.
///
/// Feature sheets used to repeat the header/divider/Flexible/
/// SingleChildScrollView block, so title size, divider colour, body padding and
/// scroll behaviour drifted apart. This frame keeps them identical and leaves
/// an optional pinned [actions] footer outside the scroll area.
class AppSheetScaffold extends StatelessWidget {
  final IconData icon;
  final Gradient? iconGradient;
  final String title;
  final String? subtitle;

  /// Fraction of the screen height the sheet may use. Landscape viewports get
  /// a larger share from [AppBottomSheet].
  final double maxHeightFactor;
  final EdgeInsetsGeometry bodyPadding;

  /// Sheet content. It scrolls; do not wrap it in another scroll view.
  final Widget body;

  /// Optional footer, usually an [AppSheetActions] row.
  final Widget? actions;

  /// Defaults to popping the sheet with a null result.
  final VoidCallback? onClose;

  const AppSheetScaffold({
    super.key,
    required this.icon,
    this.iconGradient,
    required this.title,
    this.subtitle,
    this.maxHeightFactor = 0.68,
    this.bodyPadding = const EdgeInsets.all(AppSpacing.md),
    required this.body,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      maxHeightFactor: maxHeightFactor,
      children: [
        AppBottomSheetHeader(
          icon: icon,
          iconGradient: iconGradient,
          title: title,
          subtitle: subtitle,
          onClose: onClose ?? () => Navigator.of(context).maybePop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Flexible(
          child: SingleChildScrollView(
            padding: bodyPadding,
            child: body,
          ),
        ),
        if (actions != null) actions!,
      ],
    );
  }
}
