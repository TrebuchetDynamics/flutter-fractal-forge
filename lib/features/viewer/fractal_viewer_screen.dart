import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/debug/debug_overlay.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalViewerScreen extends StatefulWidget {
  const FractalViewerScreen({Key? key}) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen> {
  final GlobalKey _fractalKey = GlobalKey();
  final ExportService _exportService = const ExportService();
  bool _exporting = false;
  double? _exportProgress;
  DebugRunnerService? _debugRunner;

  @override
  void initState() {
    super.initState();
  }

  // We must use didChangeDependencies for Provider access (not available in initState)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode && _debugRunner == null) {
      _debugRunner = DebugRunnerService(
        controller: context.read<FractalController>(),
        registry: context.read<ModuleRegistry>(),
      );
    }
  }

  @override
  void dispose() {
    _debugRunner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.module.displayName(l10n)),
        actions: [
          IconButton(
            tooltip: l10n.tooltipOpenControls,
            icon: const Icon(Icons.tune),
            onPressed: _exporting ? null : () => _openControls(context),
          ),
          IconButton(
            tooltip: l10n.tooltipOpenPresets,
            icon: const Icon(Icons.bookmark),
            onPressed: _exporting ? null : () => _openPresets(context),
          ),
          IconButton(
            tooltip: l10n.tooltipExport,
            icon: const Icon(Icons.download),
            onPressed: _exporting ? null : () => _openExport(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          FractalRenderer(boundaryKey: _fractalKey),
          if (_exporting)
            Align(
              alignment: Alignment.center,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.exporting),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 180,
                        child: LinearProgressIndicator(value: _exportProgress),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (kDebugMode && _debugRunner != null)
            DebugOverlay(
              runner: _debugRunner!,
              boundaryKey: _fractalKey,
            ),
        ],
      ),
    );
  }

  void _openControls(BuildContext context) {
    final controller = context.read<FractalController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const FractalControlsSheet(),
      ),
    );
  }

  void _openPresets(BuildContext context) {
    final controller = context.read<FractalController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const PresetSheet(),
      ),
    );
  }

  void _openExport(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.exportPng),
              onTap: () {
                Navigator.of(context).pop();
                _exportPng(context, transparent: false);
              },
            ),
            ListTile(
              title: Text(l10n.exportTransparentPng),
              onTap: () {
                Navigator.of(context).pop();
                _exportPng(context, transparent: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPng(BuildContext context, {required bool transparent}) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final previousTransparency = controller.transparentBackground;
    setState(() {
      _exporting = true;
      _exportProgress = null;
    });
    try {
      if (transparent) {
        controller.setTransparentBackground(true);
      }
      final bytes = await _exportService.capturePng(_fractalKey, pixelRatio: 2.5);
      final file = await _exportService.saveBytes(
        bytes,
        filename: 'fractal_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (mounted) {
        await _exportService.shareFile(file, text: l10n.exportTitle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      controller.setTransparentBackground(previousTransparency);
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }
}
