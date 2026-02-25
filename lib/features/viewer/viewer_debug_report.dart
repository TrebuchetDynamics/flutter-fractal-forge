part of 'fractal_viewer_screen.dart';

/// Mixin that builds and shares the GPU debug report.
///
/// Apply to `State<FractalViewerScreen>` with `_GpuHealthMixin`.
mixin _DebugReportMixin on State<FractalViewerScreen>, _GpuHealthMixin {
  // Abstract members satisfied by _FractalViewerScreenState.
  ExportService get _exportService;
  GlobalKey _activeBoundaryKey();

  Future<void> _shareGpuDebugReport(BuildContext context) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final payload = <String, Object?>{
        'timestamp': DateTime.now().toIso8601String(),
        'moduleId': controller.module.id,
        'moduleDimension': controller.module.dimension.name,
        'rendererPreference':
            context.read<RendererSettingsService>().backendMode.name,
        'backendDecision': {
          'backend': _backendDecision.backend.name,
          'reasonCode': _backendDecision.reasonToken,
          'detail': _backendDecision.detail,
        },
        'gpuHealthCheckEnabled': true,
        'lastGpuNonBlackRatio': _lastGpuNonBlackRatio,
        'lastGpuDarkRatio': _lastGpuDarkRatio,
        'lastGpuCenterNonBlack': _lastGpuCenterNonBlack,
        'lastGpuHistogramSane': _lastGpuHistogramSane,
        'lastGpuSampleCount': _lastGpuSampleCount,
        'lastGpuHealthError': _lastGpuHealthError?.toString(),
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };

      final reportText = const JsonEncoder.withIndent('  ').convert(payload);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final reportFile = await _exportService.saveBytes(
        Uint8List.fromList(reportText.codeUnits),
        filename: 'gpu_debug_${controller.module.id}_$ts.json',
      );

      File? screenshotFile;
      try {
        final png = await _exportService.capturePng(_activeBoundaryKey(),
            pixelRatio: 1.0);
        screenshotFile = await _exportService.saveBytes(
          png,
          filename: _exportService.generateFilename(
              prefix: 'gpu_debug',
              format: ExportFormat.png,
              fractalType: controller.module.id),
        );
      } catch (_) {
        // Screenshot capture can fail when GPU output is black; still share text report.
      }

      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPU Debug Report',
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ShaderLabScreen()),
                            );
                          },
                          icon: const Icon(Icons.science_rounded,
                              color: Colors.amber),
                          label: const Text('Open Shader Lab',
                              style: TextStyle(color: Colors.amber)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved report: ${reportFile.path}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (screenshotFile != null)
                    Text(
                      'Saved screenshot: ${screenshotFile.path}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        reportText,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: reportText));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Copied GPU debug JSON to clipboard. Paste it into Telegram.')),
                          );
                        },
                        child: const Text('Copy JSON'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
