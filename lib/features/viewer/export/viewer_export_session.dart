import 'package:flutter/foundation.dart';

enum ViewerExportPhase { idle, sheetOpen, exporting }

class ViewerShareCaption {
  const ViewerShareCaption._();

  /// Community handle every share carries so posts cluster under one
  /// discoverable brand on social platforms.
  static const String handle = '@FractalForgeApp';

  /// Broad hashtag: shorter and more likely to be searched than an app tag.
  static const String hashtag = '#fractal';

  /// Builds the social caption attached to a shared fractal.
  ///
  /// [shareUrl] should be a universal link (see `DeepLinkService.buildWebUri`)
  /// that reopens this exact view. Including it turns every share into a
  /// tappable, reproducible "coordinate drop" instead of plain text the viewer
  /// has to re-enter by hand.
  static String build({
    required String fractalName,
    String? shareUrl,
  }) {
    final lines = <String>['$fractalName in Fractal Forge.'];
    if (shareUrl != null && shareUrl.isNotEmpty) {
      lines.add(shareUrl);
    }
    lines.add('$handle $hashtag');
    return lines.join('\n');
  }
}

/// Normalizes export progress telemetry for determinate UI rendering.
///
/// Export backends may report malformed progress while falling back between
/// codecs or platform capture paths. Keep invalid samples indeterminate instead
/// of letting [double.clamp] turn NaN into a determinate edge value.
class ViewerExportProgress {
  const ViewerExportProgress._();

  static double? normalize(double progress) {
    if (!progress.isFinite) return null;
    return progress.clamp(0.0, 1.0).toDouble();
  }
}

@immutable
class ViewerExportAutoExplorePlayback {
  final bool isExploring;
  final bool isPaused;
  final bool pausedByUserCorrection;

  const ViewerExportAutoExplorePlayback({
    required this.isExploring,
    required this.isPaused,
    required this.pausedByUserCorrection,
  }) : assert(
          !pausedByUserCorrection || (isExploring && !isPaused),
          'pausedByUserCorrection is only valid while auto-explore is armed',
        );

  bool get isArmedButTemporarilyYielded =>
      isExploring && !isPaused && pausedByUserCorrection;
}

/// Pure pause/resume plan for export flows that temporarily suspend auto-explore.
///
/// Keeping this decision outside the viewer mixin makes the hidden replay order
/// visible: the export flow should resume auto-explore only when it paused
/// active auto-motion itself.
@immutable
class ViewerExportAutoExplorePausePlan {
  final bool pauseService;
  final bool resumeWhenFinished;

  const ViewerExportAutoExplorePausePlan({
    required this.pauseService,
    required this.resumeWhenFinished,
  });

  factory ViewerExportAutoExplorePausePlan.fromPlayback(
    ViewerExportAutoExplorePlayback playback,
  ) {
    final ownsAutoMotion = playback.isExploring &&
        !playback.isPaused &&
        !playback.pausedByUserCorrection;
    return ViewerExportAutoExplorePausePlan(
      pauseService: ownsAutoMotion,
      resumeWhenFinished: ownsAutoMotion,
    );
  }
}

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
      progress: ViewerExportProgress.normalize(nextProgress),
    );
  }

  ViewerExportSession finish() => const ViewerExportSession();
}
