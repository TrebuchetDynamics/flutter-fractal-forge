part of '../fractal_viewer_screen.dart';

/// Mixin that builds and shares the GPU debug report.
///
/// Apply to `State<FractalViewerScreen>` with `_GpuHealthMixin`.
mixin _DebugReportMixin on State<FractalViewerScreen>, _GpuHealthMixin {
  // Abstract members satisfied by _FractalViewerScreenState.
  ExportService get _exportService;
  GlobalKey _activeBoundaryKey();

  Future<void> _shareGpuDebugReport(BuildContext context) async {
    if (!await _exportService.chooseLinuxExportDirectory()) return;
    if (!context.mounted) return;

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
        'lastGpuNonBlackRatio': _gpuProbe.lastGpuNonBlackRatio,
        'lastGpuDarkRatio': _gpuProbe.lastGpuDarkRatio,
        'lastGpuCenterNonBlack': _gpuProbe.lastGpuCenterNonBlack,
        'lastGpuHistogramSane': _gpuProbe.lastGpuHistogramSane,
        'lastGpuSampleCount': _gpuProbe.lastGpuSampleCount,
        'lastGpuHealthError': _gpuProbe.lastGpuHealthError?.toString(),
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'platformVersion': kIsWeb ? '' : Platform.operatingSystemVersion,
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
          return AppBottomSheet(
            maxHeightFactor: 0.72,
            children: [
              AppBottomSheetHeader(
                icon: Icons.science_rounded,
                iconGradient: const LinearGradient(
                  colors: [Colors.amber, AppColors.warning],
                ),
                title: 'GPU Debug Report',
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ShaderLabScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.science_rounded),
                          label: Text(
                            AppLocalizations.of(context)!
                                .debugReportOpenShaderLab,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saved report: ${reportFile.path}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (screenshotFile != null)
                        Text(
                          'Saved screenshot: ${screenshotFile.path}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            reportText,
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textPrimary,
                            ),
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
                              Clipboard.setData(
                                  ClipboardData(text: reportText));
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Copied GPU debug JSON to clipboard. Paste it into Telegram.',
                                  ),
                                ),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!
                                .debugReportCopyJson),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child:
                                Text(AppLocalizations.of(context)!.actionClose),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
