import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/debug/debug_overlay.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalViewerScreen extends StatefulWidget {
  const FractalViewerScreen({Key? key}) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _fractalKey = GlobalKey();
  final ExportService _exportService = const ExportService();
  bool _exporting = false;
  double? _exportProgress;
  DebugRunnerService? _debugRunner;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    )..forward();
  }

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
    _fabController.dispose();
    _debugRunner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _PremiumViewerAppBar(
        title: controller.module.displayName(l10n),
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Stack(
        children: [
          // Fractal renderer (full screen)
          Positioned.fill(
            child: FractalRenderer(boundaryKey: _fractalKey),
          ),

          // Floating action buttons
          Positioned(
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
            child: FadeTransition(
              opacity: _fabController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _fabController,
                  curve: AppAnimations.defaultCurve,
                )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FloatingActionButton(
                      icon: Icons.tune_rounded,
                      tooltip: l10n.tooltipOpenControls,
                      onPressed: _exporting ? null : () => _openControls(context),
                      delay: const Duration(milliseconds: 0),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FloatingActionButton(
                      icon: Icons.bookmark_rounded,
                      tooltip: l10n.tooltipOpenPresets,
                      onPressed: _exporting ? null : () => _openPresets(context),
                      delay: const Duration(milliseconds: 50),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FloatingActionButton(
                      icon: Icons.download_rounded,
                      tooltip: l10n.tooltipExport,
                      onPressed: _exporting ? null : () => _openExport(context),
                      isPrimary: true,
                      delay: const Duration(milliseconds: 100),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Export progress overlay
          if (_exporting)
            Positioned.fill(
              child: _ExportOverlay(
                progress: _exportProgress,
                l10n: l10n,
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
      backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const PresetSheet(),
      ),
    );
  }

  void _openExport(BuildContext context) {
    final controller = context.read<FractalController>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportOptionsSheet(
        initialOptions: const ExportOptions(),
        fractalType: controller.module.id,
        onExport: (options) => _performExport(context, options),
      ),
    );
  }

  Future<void> _performExport(BuildContext context, ExportOptions options) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final previousTransparency = controller.transparentBackground;
    
    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });
    
    try {
      // Set transparency if requested
      if (options.transparentBackground) {
        controller.setTransparentBackground(true);
        // Wait for the widget to repaint
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Perform the export
      final result = await _exportService.exportWithOptions(
        _fractalKey,
        options: options,
        screenWidth: size.width,
        screenHeight: size.height,
        fractalType: controller.module.id,
        parameters: controller.params,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _exportProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        // Share the file
        await _exportService.shareFile(result.file, text: l10n.exportTitle);
        
        // Show success message with details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.exportSaved),
                      Text(
                        '${result.resolution} • ${result.format.displayName} • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // Restore transparency setting
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

class _PremiumViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const _PremiumViewerAppBar({
    required this.title,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.9),
                AppColors.background.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.xs),
                  _AnimatedBackButton(onPressed: onBack),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FadeIn(
                      child: Text(
                        title,
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedBackButton({required this.onPressed});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FloatingActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Duration delay;

  const _FloatingActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
    this.delay = Duration.zero,
  });

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: widget.delay,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTapDown: widget.onPressed != null ? (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          } : null,
          onTapUp: widget.onPressed != null ? (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          } : null,
          onTapCancel: widget.onPressed != null ? () {
            setState(() => _isPressed = false);
            _controller.reverse();
          } : null,
          onTap: widget.onPressed,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: widget.isPrimary ? AppColors.primaryGradient : null,
                color: widget.isPrimary ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: widget.isPrimary ? null : Border.all(
                  color: _isPressed
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? AppColors.primary.withValues(alpha: _isPressed ? 0.5 : 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: _isPressed ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.isPrimary
                    ? Colors.white
                    : (_isPressed ? AppColors.primary : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportOverlay extends StatelessWidget {
  final double? progress;
  final AppLocalizations l10n;

  const _ExportOverlay({
    required this.progress,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withValues(alpha: 0.7),
        child: Center(
          child: FadeIn(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.downloading_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.exporting,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${(progress! * 100).round()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
