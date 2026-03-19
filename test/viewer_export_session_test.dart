import 'package:flutter_fractals/features/viewer/viewer_export_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
