import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/batch_export_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class BatchExportDialog extends StatefulWidget {
  final GlobalKey boundaryKey;

  const BatchExportDialog({
    super.key,
    required this.boundaryKey,
  });

  @override
  State<BatchExportDialog> createState() => _BatchExportDialogState();
}

class _BatchExportDialogState extends State<BatchExportDialog> {
  final _service = const BatchExportService();

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _running = false;
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog.fullscreen(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.batchExportTitle,
                      style: AppTypography.headlineSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _cancelOrClose,
                    child: Text(_running ? l10n.batchExportCancel : l10n.actionClose),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status,
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
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.exportFailed(_error.toString()),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        _running ? l10n.batchExportPreparing : l10n.batchExportDone,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    if (_contactSheet != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          '${l10n.batchExportContactSheet}: ${_contactSheet!.path}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
          ],
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
            Image.file(file, fit: BoxFit.cover),
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
