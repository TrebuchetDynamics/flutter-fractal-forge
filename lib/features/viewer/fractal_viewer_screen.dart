import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/services/performance_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/debug/debug_overlay.dart';
import 'package:flutter_fractals/features/debug/performance_overlay.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
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
    with TickerProviderStateMixin {
  final GlobalKey _fractalKey = GlobalKey();
  final ExportService _exportService = const ExportService();
  bool _exporting = false;
  double? _exportProgress;
  DebugRunnerService? _debugRunner;
  late AnimationController _fabController;
  
  // Performance overlay state
  final PerformanceService _performanceService = PerformanceService();
  bool _showPerformanceOverlay = false;
  bool _compactPerformanceOverlay = false;
  
  // History tracking
  FractalController? _lastController;

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
    
    // Set up history tracking
    final controller = context.read<FractalController>();
    if (_lastController != controller) {
      _lastController?.removeListener(_onControllerChanged);
      _lastController = controller;
      controller.addListener(_onControllerChanged);
      // Record initial state
      _recordHistory(context);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      _recordHistory(context);
    }
  }

  @override
  void dispose() {
    _lastController?.removeListener(_onControllerChanged);
    _fabController.dispose();
    _debugRunner?.dispose();
    _performanceService.dispose();
    super.dispose();
  }

  void _togglePerformanceOverlay() {
    setState(() {
      _showPerformanceOverlay = !_showPerformanceOverlay;
      if (_showPerformanceOverlay) {
        _performanceService.start(this);
      } else {
        _performanceService.stop();
      }
    });
  }

  void _toggleCompactMode() {
    setState(() {
      _compactPerformanceOverlay = !_compactPerformanceOverlay;
    });
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
            child: FractalRenderer(
              boundaryKey: _fractalKey,
              onOpenControls: () => _openControls(context),
              onOpenPresets: () => _openPresets(context),
              onOpenExport: () => _openExport(context),
            ),
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
                      icon: Icons.history_rounded,
                      tooltip: l10n.tooltipOpenHistory,
                      onPressed: _exporting ? null : () => _openHistory(context),
                      delay: const Duration(milliseconds: 75),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FloatingActionButton(
                      icon: Icons.share_rounded,
                      tooltip: l10n.tooltipShare,
                      onPressed: _exporting ? null : () => _shareFractal(context),
                      delay: const Duration(milliseconds: 100),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FloatingActionButton(
                      icon: Icons.download_rounded,
                      tooltip: l10n.tooltipExport,
                      onPressed: _exporting ? null : () => _openExport(context),
                      isPrimary: true,
                      delay: const Duration(milliseconds: 125),
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

          // Performance overlay toggle button (top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            left: AppSpacing.md,
            child: GestureDetector(
              onLongPress: _showPerformanceOverlay ? _toggleCompactMode : null,
              child: PerformanceToggleButton(
                isEnabled: _showPerformanceOverlay,
                onToggle: _togglePerformanceOverlay,
              ),
            ),
          ),

          // Performance overlay (top-left, below toggle)
          if (_showPerformanceOverlay)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 48,
              left: AppSpacing.md,
              child: FractalPerformanceOverlay(
                service: _performanceService,
                compact: _compactPerformanceOverlay,
              ),
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

  void _openHistory(BuildContext context) {
    final controller = context.read<FractalController>();
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider.value(value: historyProvider),
        ],
        child: const HistorySheet(),
      ),
    );
  }

  /// Records the current location in history.
  void _recordHistory(BuildContext context) {
    final controller = context.read<FractalController>();
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;

    historyProvider.recordLocation(
      moduleId: controller.module.id,
      view: controller.view,
      params: controller.params,
    );
  }

  /// Shares the current fractal configuration via deep link.
  void _shareFractal(BuildContext context) {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    // Build the deep link URL
    final uri = DeepLinkService.buildUri(
      moduleId: controller.module.id,
      params: controller.params,
      view: controller.view,
    );

    // Show a bottom sheet with sharing options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(
        uri: uri,
        fractalName: controller.module.displayName(l10n),
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
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onPressed != null,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTapDown: (widget.onPressed != null && !reduceMotion) ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            } : null,
            onTapUp: (widget.onPressed != null && !reduceMotion) ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
            } : null,
            onTapCancel: (widget.onPressed != null && !reduceMotion) ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            } : null,
            onTap: widget.onPressed,
            child: reduceMotion 
                ? _buildButtonContent()
                : ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildButtonContent(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return AnimatedContainer(
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

/// Bottom sheet for sharing fractal configuration via deep link.
class _ShareSheet extends StatelessWidget {
  final Uri uri;
  final String fractalName;

  const _ShareSheet({
    required this.uri,
    required this.fractalName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final linkText = uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                l10n.shareTitle,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.shareSubtitle(fractalName),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Link preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        linkText,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Share buttons
              Row(
                children: [
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.copy_rounded,
                      label: l10n.actionCopy,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: linkText));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_rounded, color: AppColors.success, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(l10n.linkCopied),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.share_rounded,
                      label: l10n.actionShare,
                      isPrimary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Share.share(
                          l10n.shareMessage(fractalName, linkText),
                          subject: l10n.shareSubject(fractalName),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppColors.primaryGradient : null,
            color: widget.isPrimary ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: widget.isPrimary ? null : Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color: widget.isPrimary ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
