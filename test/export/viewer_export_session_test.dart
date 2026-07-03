import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewerExportAutoExplorePausePlan', () {
    test('does not resume auto-explore that was already yielded to the user',
        () {
      const playback = ViewerExportAutoExplorePlayback(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: true,
      );

      final plan = ViewerExportAutoExplorePausePlan.fromPlayback(playback);

      expect(playback.isArmedButTemporarilyYielded, isTrue);
      expect(plan.pauseService, isFalse);
      expect(plan.resumeWhenFinished, isFalse);
    });

    test('pauses and resumes only active auto-motion', () {
      final activePlan = ViewerExportAutoExplorePausePlan.fromPlayback(
        const ViewerExportAutoExplorePlayback(
          isExploring: true,
          isPaused: false,
          pausedByUserCorrection: false,
        ),
      );
      final pausedPlan = ViewerExportAutoExplorePausePlan.fromPlayback(
        const ViewerExportAutoExplorePlayback(
          isExploring: true,
          isPaused: true,
          pausedByUserCorrection: false,
        ),
      );
      final idlePlan = ViewerExportAutoExplorePausePlan.fromPlayback(
        const ViewerExportAutoExplorePlayback(
          isExploring: false,
          isPaused: false,
          pausedByUserCorrection: false,
        ),
      );

      expect(activePlan.pauseService, isTrue);
      expect(activePlan.resumeWhenFinished, isTrue);
      expect(pausedPlan.pauseService, isFalse);
      expect(pausedPlan.resumeWhenFinished, isFalse);
      expect(idlePlan.pauseService, isFalse);
      expect(idlePlan.resumeWhenFinished, isFalse);
    });
  });

  group('ViewerExportSession', () {
    test('freezes while sheet is open and resumes to idle when dismissed', () {
      final session = const ViewerExportSession().openSheet(
        resumeAutoExploreWhenFinished: true,
      );

      expect(session.phase, ViewerExportPhase.sheetOpen);
      expect(session.freezeFrame, isTrue);
      expect(session.isExporting, isFalse);
      expect(session.resumeAutoExploreWhenFinished, isTrue);

      final dismissed = session.dismissSheet();
      expect(dismissed.phase, ViewerExportPhase.idle);
      expect(dismissed.freezeFrame, isFalse);
      expect(dismissed.resumeAutoExploreWhenFinished, isFalse);
    });

    test('stays exporting when sheet dismisses after export has started', () {
      final exporting = const ViewerExportSession()
          .openSheet(resumeAutoExploreWhenFinished: true)
          .startExport()
          .updateProgress(0.5);

      final afterDismiss = exporting.dismissSheet();
      expect(afterDismiss.phase, ViewerExportPhase.exporting);
      expect(afterDismiss.freezeFrame, isTrue);
      expect(afterDismiss.isExporting, isTrue);
      expect(afterDismiss.progress, 0.5);
      expect(afterDismiss.resumeAutoExploreWhenFinished, isTrue);
    });

    test('finish resets the session back to idle', () {
      final finished = const ViewerExportSession()
          .openSheet(resumeAutoExploreWhenFinished: true)
          .startExport()
          .finish();

      expect(finished.phase, ViewerExportPhase.idle);
      expect(finished.freezeFrame, isFalse);
      expect(finished.isExporting, isFalse);
      expect(finished.progress, isNull);
      expect(finished.resumeAutoExploreWhenFinished, isFalse);
    });

    test('progress is clamped to a valid export range', () {
      final exporting = const ViewerExportSession()
          .openSheet(resumeAutoExploreWhenFinished: true)
          .startExport();

      expect(exporting.updateProgress(-1).progress, 0);
      expect(exporting.updateProgress(2).progress, 1);
    });

    test('non-finite progress falls back to indeterminate progress', () {
      final exporting = const ViewerExportSession()
          .openSheet(resumeAutoExploreWhenFinished: true)
          .startExport();

      for (final sample in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          exporting.updateProgress(sample).progress,
          isNull,
          reason: 'sample=$sample',
        );
      }
    });

    test('startExport is a no-op once export is already active', () {
      final exporting = const ViewerExportSession()
          .openSheet(resumeAutoExploreWhenFinished: true)
          .startExport()
          .updateProgress(0.4);

      final restarted = exporting.startExport();

      expect(restarted.phase, ViewerExportPhase.exporting);
      expect(restarted.progress, 0.4);
      expect(restarted.resumeAutoExploreWhenFinished, isTrue);
    });
  });
}
