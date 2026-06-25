import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final bool isExporting;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenRandomFractal;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenPresets;
  final VoidCallback onResetView;
  final VoidCallback onResetParams;
  final VoidCallback onRandomizeParams;
  final VoidCallback onDecreaseIterations;
  final VoidCallback onIncreaseIterations;
  final VoidCallback onCycleColorScheme;
  final VoidCallback onOpenPalettePicker;
  final bool kaleidoscopeEnabled;
  final VoidCallback onToggleKaleidoscope;
  final VoidCallback onOpenExport;
  final VoidCallback onShareImage;
  final VoidCallback onOpenLooper;
  final VoidCallback onOpenWallpaper;

  const FractalViewControls({
    super.key,
    required this.fabController,
    required this.isExporting,
    required this.onToggleFullscreen,
    required this.onOpenRandomFractal,
    required this.onOpenControls,
    required this.onOpenPresets,
    required this.onResetView,
    required this.onResetParams,
    required this.onRandomizeParams,
    required this.onDecreaseIterations,
    required this.onIncreaseIterations,
    required this.onCycleColorScheme,
    required this.onOpenPalettePicker,
    required this.kaleidoscopeEnabled,
    required this.onToggleKaleidoscope,
    required this.onOpenExport,
    required this.onShareImage,
    required this.onOpenLooper,
    required this.onOpenWallpaper,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: fabController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: fabController,
          curve: AppAnimations.defaultCurve,
        )),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerFullscreenButton'),
                  icon: Icons.fullscreen_rounded,
                  tooltip: l10n.tooltipFullscreen,
                  onPressed: isExporting ? null : onToggleFullscreen,
                  delay: const Duration(milliseconds: 60),
                ),
                const SizedBox(height: AppSpacing.md),
                // Keep the viewer uncluttered: only core actions here.
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerControlsButton'),
                  icon: Icons.tune_rounded,
                  tooltip: l10n.tooltipOpenControls,
                  onPressed: isExporting ? null : onOpenControls,
                  delay: const Duration(milliseconds: 120),
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuickFabGrid(
                  isExporting: isExporting,
                  l10n: l10n,
                  onOpenPresets: onOpenPresets,
                  onResetView: onResetView,
                  onResetParams: onResetParams,
                ),
                const SizedBox(height: AppSpacing.sm),
                _TuneFabGrid(
                  isExporting: isExporting,
                  l10n: l10n,
                  onDecreaseIterations: onDecreaseIterations,
                  onIncreaseIterations: onIncreaseIterations,
                  onCycleColorScheme: onCycleColorScheme,
                  onOpenPalettePicker: onOpenPalettePicker,
                  kaleidoscopeEnabled: kaleidoscopeEnabled,
                  onToggleKaleidoscope: onToggleKaleidoscope,
                ),
                const SizedBox(height: AppSpacing.md),
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerRandomButton'),
                  icon: Icons.casino_rounded,
                  tooltip:
                      '${l10n.randomize}. Long press for ${l10n.tooltipRandomFractal}',
                  onPressed: isExporting ? null : onRandomizeParams,
                  onLongPress: isExporting ? null : onOpenRandomFractal,
                  isPrimary: true,
                  delay: const Duration(milliseconds: 135),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExportWallpaperFab(
                  isExporting: isExporting,
                  l10n: l10n,
                  onOpenExport: onOpenExport,
                  onShareImage: onShareImage,
                  onOpenLooper: onOpenLooper,
                  onOpenWallpaper: onOpenWallpaper,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportWallpaperFab extends StatelessWidget {
  final bool isExporting;
  final AppLocalizations l10n;
  final VoidCallback onOpenExport;
  final VoidCallback onShareImage;
  final VoidCallback onOpenLooper;
  final VoidCallback onOpenWallpaper;

  const _ExportWallpaperFab({
    required this.isExporting,
    required this.l10n,
    required this.onOpenExport,
    required this.onShareImage,
    required this.onOpenLooper,
    required this.onOpenWallpaper,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: const ValueKey('viewerExportButton'),
      enabled: !isExporting,
      tooltip: '${l10n.tooltipExport} / ${l10n.wallpaperTitle}',
      color: AppColors.surfaceElevated,
      onSelected: (value) {
        if (value == 'wallpaper') {
          onOpenWallpaper();
        } else if (value == 'share') {
          onShareImage();
        } else if (value == 'looper') {
          onOpenLooper();
        } else {
          onOpenExport();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const ValueKey('viewerExportMenuItem'),
          value: 'export',
          child:
              _MenuRow(icon: Icons.download_rounded, label: l10n.tooltipExport),
        ),
        const PopupMenuItem(
          key: ValueKey('viewerShareMenuItem'),
          value: 'share',
          child: _MenuRow(
            icon: Icons.share_rounded,
            label: 'Share to X / Reddit',
          ),
        ),
        const PopupMenuItem(
          key: ValueKey('viewerLooperMenuItem'),
          value: 'looper',
          child: _MenuRow(
            icon: Icons.loop_rounded,
            label: 'Looper / GIF',
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('viewerWallpaperMenuItem'),
          value: 'wallpaper',
          child: _MenuRow(
              icon: Icons.wallpaper_rounded, label: l10n.wallpaperTitle),
        ),
      ],
      child: _FabMenuShell(
        icon: Icons.ios_share_rounded,
        enabled: !isExporting,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FabMenuShell extends StatelessWidget {
  final IconData icon;
  final bool enabled;

  const _FabMenuShell({required this.icon, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 22,
        color: enabled ? AppColors.textSecondary : AppColors.textMuted,
      ),
    );
  }
}

class _QuickFabGrid extends StatelessWidget {
  final bool isExporting;
  final AppLocalizations l10n;
  final VoidCallback onOpenPresets;
  final VoidCallback onResetView;
  final VoidCallback onResetParams;

  const _QuickFabGrid({
    required this.isExporting,
    required this.l10n,
    required this.onOpenPresets,
    required this.onResetView,
    required this.onResetParams,
  });

  @override
  Widget build(BuildContext context) {
    final action = isExporting ? null : onOpenPresets;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButtonWidget(
            key: const ValueKey('viewerPresetsButton'),
            icon: Icons.bookmarks_rounded,
            tooltip: l10n.tooltipOpenPresets,
            onPressed: action,
            isCompact: true,
            delay: const Duration(milliseconds: 130),
          ),
          const SizedBox(width: 5),
          FloatingActionButtonWidget(
            key: const ValueKey('viewerResetButton'),
            icon: Icons.center_focus_strong_rounded,
            tooltip: '${l10n.resetView}. Long press for ${l10n.resetParams}',
            onPressed: isExporting ? null : onResetView,
            onLongPress: isExporting ? null : onResetParams,
            isCompact: true,
            delay: const Duration(milliseconds: 140),
          ),
        ],
      ),
    );
  }
}

class _TuneFabGrid extends StatelessWidget {
  final bool isExporting;
  final AppLocalizations l10n;
  final VoidCallback onDecreaseIterations;
  final VoidCallback onIncreaseIterations;
  final VoidCallback onCycleColorScheme;
  final VoidCallback onOpenPalettePicker;
  final bool kaleidoscopeEnabled;
  final VoidCallback onToggleKaleidoscope;

  const _TuneFabGrid({
    required this.isExporting,
    required this.l10n,
    required this.onDecreaseIterations,
    required this.onIncreaseIterations,
    required this.onCycleColorScheme,
    required this.onOpenPalettePicker,
    required this.kaleidoscopeEnabled,
    required this.onToggleKaleidoscope,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButtonWidget(
            key: const ValueKey('viewerIterationsButton'),
            icon: Icons.exposure_plus_1_rounded,
            tooltip: '${l10n.paramIterations} +. Long press for −',
            onPressed: isExporting ? null : onIncreaseIterations,
            onLongPress: isExporting ? null : onDecreaseIterations,
            isCompact: true,
            delay: const Duration(milliseconds: 165),
          ),
          const SizedBox(width: 5),
          FloatingActionButtonWidget(
            key: const ValueKey('viewerColorCycleButton'),
            icon: Icons.palette_rounded,
            tooltip: '${l10n.paramColorScheme}. Long press for palette',
            onPressed: isExporting ? null : onCycleColorScheme,
            onLongPress: isExporting ? null : onOpenPalettePicker,
            isCompact: true,
            delay: const Duration(milliseconds: 175),
          ),
          const SizedBox(width: 5),
          FloatingActionButtonWidget(
            key: const ValueKey('viewerKaleidoscopeButton'),
            icon: Icons.filter_vintage_rounded,
            tooltip:
                kaleidoscopeEnabled ? 'Kaleidoscope on' : 'Kaleidoscope off',
            onPressed: isExporting ? null : onToggleKaleidoscope,
            isPrimary: kaleidoscopeEnabled,
            isCompact: true,
            delay: const Duration(milliseconds: 185),
          ),
        ],
      ),
    );
  }
}

class FloatingActionButtonWidget extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isPrimary;
  final bool isCompact;
  final Duration delay;

  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.onLongPress,
    this.isPrimary = false,
    this.isCompact = false,
    this.delay = Duration.zero,
  });

  @override
  State<FloatingActionButtonWidget> createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
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
            onTapDown: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = true);
                    _controller.forward();
                    HapticService.medium();
                  }
                : null,
            onTapUp: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTapCancel: (widget.onPressed != null && !reduceMotion)
                ? () {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
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
      width: widget.isCompact ? 42 : 52,
      height: widget.isCompact ? 42 : 52,
      decoration: BoxDecoration(
        gradient: widget.isPrimary ? AppColors.primaryGradient : null,
        color: widget.isPrimary ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.isPrimary
            ? null
            : Border.all(
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
        size: widget.isCompact ? 19 : 22,
        color: widget.isPrimary
            ? Colors.white
            : (_isPressed ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}
