import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/export/batch_export_service.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class BatchExportDialog extends StatefulWidget {
  final GlobalKey boundaryKey;

  /// Backends, overridable so the dialog's states can be driven in a test.
  ///
  /// Both were constructed inline, and the first thing the dialog does is ask
  /// [ExportService] for an export directory — which opens a real picker. That
  /// future never resolves under test, so the dialog sat on its first frame
  /// with an empty status and an empty grid: the progress states, the item
  /// grid, the error panel and the saved-path footer had never been rendered.
  /// Both default to the real services.
  final ExportService? exportService;
  final BatchExportService? batchExportService;

  const BatchExportDialog({
    super.key,
    required this.boundaryKey,
    this.exportService,
    this.batchExportService,
  });

  @override
  State<BatchExportDialog> createState() => _BatchExportDialogState();
}

class _BatchExportDialogState extends State<BatchExportDialog> {
  BatchExportService get _service =>
      widget.batchExportService ?? const BatchExportService();
  ExportService get _exportService =>
      widget.exportService ?? const ExportService();

  bool _running = true;
  bool _cancelled = false;
  double _progress = 0;
  String _status = '';
  Directory? _outDir;
  File? _contactSheet;
  final List<BatchExportItemResult> _items = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _run();
    });
  }

  Future<void> _run() async {
    if (kIsWeb) {
      setState(() {
        _running = false;
        _error = UnsupportedError('Batch export is not supported on web');
      });
      return;
    }
    final controller = context.read<FractalController>();
    final presetStore = context.read<PresetStore>();
    final l10n = AppLocalizations.of(context)!;

    if (!await _exportService.chooseLinuxExportDirectory()) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _cancelled = true;
        _status = l10n.batchExportCancelled;
      });
      return;
    }
    if (!mounted) return;

    final initialModule = controller.module;
    final initialParams = Map<String, Object>.from(controller.params);
    final initialView = controller.view;
    final initialTransparent = controller.transparentBackground;

    setState(() {
      _status = l10n.batchExportPreparing;
    });

    try {
      final builtIn = controller.module.builtInPresets;
      final user = await presetStore.loadUserPresets(controller.module.id);
      if (!mounted) return;
      final presets = <FractalPreset>[...builtIn, ...user];

      if (presets.isEmpty) {
        setState(() {
          _running = false;
          _status = l10n.batchExportNoPresets;
        });
        return;
      }

      const options = ExportOptions(
        format: ExportFormat.png,
        resolution: ExportResolution.fullHd,
        embedMetadata: true,
      );

      controller.setTransparentBackground(options.transparentBackground);

      final size = MediaQuery.of(context).size;

      final result = await _service.exportPresets(
        boundaryKey: widget.boundaryKey,
        applyPreset: (preset) async {
          if (preset.moduleId != controller.module.id) return;
          controller.applyPreset(preset);
        },
        presets: presets,
        options: options,
        screenWidth: size.width,
        screenHeight: size.height,
        moduleId: controller.module.id,
        moduleDisplayName: controller.module.displayName(l10n),
        currentParameters: () => controller.params,
        onProgress: (p, status) {
          if (!mounted) return;
          setState(() {
            _progress = p;
            _status = status;
          });
        },
        onItemDone: (item) {
          if (!mounted) return;
          setState(() {
            _items.add(item);
          });
        },
        isCancelled: () => _cancelled,
      );

      if (!mounted) return;
      setState(() {
        _outDir = result.directory;
        _contactSheet = result.contactSheet;
        _running = false;
        _status = _cancelled ? l10n.batchExportCancelled : l10n.batchExportDone;
        _progress = 1.0;
      });
    } on ExportCancelledException {
      if (!mounted) return;
      setState(() {
        _running = false;
        _cancelled = true;
        _status = l10n.batchExportCancelled;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _running = false;
        // Left as-is this still read "Preparing…" under "Export failed".
        _status = '';
      });
    } finally {
      controller.loadState(
        module: initialModule,
        params: initialParams,
        view: initialView,
        transparentBackground: initialTransparent,
        animateModule: false,
      );
    }
  }

  void _cancelOrClose() {
    final l10n = AppLocalizations.of(context)!;
    if (!_running) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _cancelled = true;
      _status = l10n.batchExportCancelling;
    });
    _service.cancelActiveExport();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelOrClose();
      },
      child: Dialog.fullscreen(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              AppBottomSheetHeader(
                icon: Icons.collections_rounded,
                title: l10n.batchExportTitle,
                subtitle: _running ? l10n.batchExportCancel : l10n.actionClose,
                onClose: _cancelOrClose,
              ),
              const Divider(height: 1, color: AppColors.divider),
              // Everything below the header scrolls as one body.
              //
              // It used to be fixed chrome around a single Expanded holding the
              // grid, so as the text scale grew the status line, error panel and
              // saved-path footer took the height and the grid was starved: at
              // 2.0x and above it measured 0px on every viewport tried and the
              // exported images simply were not shown, while the column
              // overflowed its bottom by up to 784px.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _status,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            LinearProgressIndicator(
                              value: _running ? _progress.clamp(0.0, 1.0) : 1.0,
                              backgroundColor: AppColors.surfaceVariant,
                              color: AppColors.primary,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.error),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    l10n.exportFailed(_error.toString()),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall
                                        .copyWith(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      _items.isEmpty
                          ? Center(
                              // Silent when failure or cancellation is already
                              // reported by the primary status above.
                              child: _error != null || _cancelled
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _running
                                          ? l10n.batchExportPreparing
                                          : l10n.batchExportDone,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: GridView.builder(
                                // Sized by its content now that the body scrolls;
                                // the outer scroll view owns the scrolling.
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _ExportThumbTile(
                                    name: item.preset.name,
                                    file: item.file,
                                  );
                                },
                              ),
                            ),
                      if (!_running && _outDir != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.batchExportSavedTo} ${_outDir!.path}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              if (_contactSheet != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    '${l10n.batchExportContactSheet}: ${_contactSheet!.path}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportThumbTile extends StatelessWidget {
  final String name;
  final File file;

  const _ExportThumbTile({
    required this.name,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              file,
              fit: BoxFit.cover,
              cacheWidth: 256,
              cacheHeight: 256,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
