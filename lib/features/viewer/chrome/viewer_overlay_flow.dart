import 'package:flutter/material.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

/// One flow for viewer overlays: pause motion, present, pop, dispatch, restore.
///
/// Callers declare content and a result type. The flow owns the order, so a new
/// overlay cannot forget to stop motion or to run its command on a mounted
/// context after the sheet closes.
class ViewerOverlayFlow {
  const ViewerOverlayFlow({required this.context, this.pauseMotion});

  final BuildContext context;
  final VoidCallback? pauseMotion;

  /// Present a sheet and return its typed result.
  Future<T?> present<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    BoxConstraints? constraints,
  }) {
    pauseMotion?.call();
    return showAppBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      constraints: constraints,
    );
  }

  /// Present a command sheet, then run the chosen command on the still-mounted
  /// viewer context. A dismissed sheet runs nothing.
  Future<void> presentCommand({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) async {
    final command = await present<VoidCallback>(
      builder: builder,
      isScrollControlled: isScrollControlled,
    );
    if (context.mounted) command?.call();
  }

  /// Present the shared options frame with a title, subtitle and content.
  Future<T?> presentOptions<T>({
    required IconData icon,
    required String title,
    String? subtitle,
    double maxHeightFactor = 0.78,
    required Widget child,
  }) =>
      present<T>(
        builder: (_) => AppOptionsSheet(
          icon: icon,
          title: title,
          subtitle: subtitle,
          maxHeightFactor: maxHeightFactor,
          child: child,
        ),
      );
}
