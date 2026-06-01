part of '../fractal_viewer_screen.dart';

void _viewerRecordHistory(BuildContext context) {
  final controller = context.read<FractalController>();
  final historyProvider = context.read<HistoryProvider?>();
  if (historyProvider == null) return;

  historyProvider.recordLocation(
    moduleId: controller.module.id,
    view: controller.view,
    params: controller.params,
  );
}
