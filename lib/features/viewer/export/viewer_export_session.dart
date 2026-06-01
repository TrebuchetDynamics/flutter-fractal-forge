import 'package:flutter/foundation.dart';

enum ViewerExportPhase { idle, sheetOpen, exporting }

@immutable
class ViewerExportSession {
  final ViewerExportPhase phase;
  final bool resumeAutoExploreWhenFinished;
  final double? progress;

  const ViewerExportSession({
    this.phase = ViewerExportPhase.idle,
    this.resumeAutoExploreWhenFinished = false,
    this.progress,
  });

  bool get freezeFrame => phase != ViewerExportPhase.idle;
  bool get isExporting => phase == ViewerExportPhase.exporting;
  bool get isSheetOpen => phase == ViewerExportPhase.sheetOpen;

  ViewerExportSession openSheet({
    required bool resumeAutoExploreWhenFinished,
  }) {
    return ViewerExportSession(
      phase: ViewerExportPhase.sheetOpen,
      resumeAutoExploreWhenFinished: resumeAutoExploreWhenFinished,
    );
  }

  ViewerExportSession dismissSheet() {
    if (!isSheetOpen) return this;
    return const ViewerExportSession();
  }

  ViewerExportSession startExport() {
    if (isExporting) return this;
    return ViewerExportSession(
      phase: ViewerExportPhase.exporting,
      resumeAutoExploreWhenFinished: resumeAutoExploreWhenFinished,
      progress: 0,
    );
  }

  ViewerExportSession updateProgress(double nextProgress) {
    if (!isExporting) return this;
    return ViewerExportSession(
      phase: phase,
      resumeAutoExploreWhenFinished: resumeAutoExploreWhenFinished,
      progress: nextProgress.clamp(0.0, 1.0).toDouble(),
    );
  }

  ViewerExportSession finish() => const ViewerExportSession();
}
