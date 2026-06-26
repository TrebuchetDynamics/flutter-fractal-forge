import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalViewControlActions {
  final VoidCallback toggleFullscreen;
  final VoidCallback openRandomFractal;
  final VoidCallback openControls;
  final VoidCallback openPresets;
  final VoidCallback resetView;
  final VoidCallback resetParams;
  final VoidCallback randomizeParams;
  final VoidCallback decreaseIterations;
  final VoidCallback increaseIterations;
  final VoidCallback cycleColorScheme;
  final VoidCallback openPalettePicker;
  final VoidCallback toggleKaleidoscope;
  final VoidCallback openExport;
  final VoidCallback shareImage;
  final VoidCallback openLooper;
  final VoidCallback openWallpaper;

  const FractalViewControlActions({
    required this.toggleFullscreen,
    required this.openRandomFractal,
    required this.openControls,
    required this.openPresets,
    required this.resetView,
    required this.resetParams,
    required this.randomizeParams,
    required this.decreaseIterations,
    required this.increaseIterations,
    required this.cycleColorScheme,
    required this.openPalettePicker,
    required this.toggleKaleidoscope,
    required this.openExport,
    required this.shareImage,
    required this.openLooper,
    required this.openWallpaper,
  });
}

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final bool isExporting;
  final bool kaleidoscopeEnabled;
  final FractalViewControlActions actions;

  const FractalViewControls({
    super.key,
    required this.fabController,
    required this.isExporting,
    required this.kaleidoscopeEnabled,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final actionButtons = <Widget>[
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFullscreenButton'),
        icon: Icons.fullscreen_rounded,
        tooltip: l10n.tooltipFullscreen,
        onPressed: isExporting ? null : actions.toggleFullscreen,
        isCompact: true,
        delay: const Duration(milliseconds: 60),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerControlsButton'),
        icon: Icons.tune_rounded,
        tooltip: l10n.tooltipOpenControls,
        onPressed: isExporting ? null : actions.openControls,
        isCompact: true,
        delay: const Duration(milliseconds: 80),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerPresetsButton'),
        icon: Icons.bookmarks_rounded,
        tooltip: l10n.tooltipOpenPresets,
        onPressed: isExporting ? null : actions.openPresets,
        isCompact: true,
        delay: const Duration(milliseconds: 100),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerResetButton'),
        icon: Icons.center_focus_strong_rounded,
        tooltip: l10n.tooltipResetViewWithParams,
        onPressed: isExporting ? null : actions.resetView,
        onLongPress: isExporting ? null : actions.resetParams,
        isCompact: true,
        delay: const Duration(milliseconds: 120),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerIterationsButton'),
        icon: Icons.exposure_plus_1_rounded,
        tooltip: l10n.tooltipIncreaseIterationsWithDecrease,
        onPressed: isExporting ? null : actions.increaseIterations,
        onLongPress: isExporting ? null : actions.decreaseIterations,
        isCompact: true,
        delay: const Duration(milliseconds: 140),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerColorCycleButton'),
        icon: Icons.palette_rounded,
        tooltip: l10n.tooltipColorSchemeWithPalette,
        onPressed: isExporting ? null : actions.cycleColorScheme,
        onLongPress: isExporting ? null : actions.openPalettePicker,
        isCompact: true,
        delay: const Duration(milliseconds: 160),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerKaleidoscopeButton'),
        icon: Icons.filter_vintage_rounded,
        tooltip: kaleidoscopeEnabled
            ? l10n.tooltipKaleidoscopeOn
            : l10n.tooltipKaleidoscopeOff,
        onPressed: isExporting ? null : actions.toggleKaleidoscope,
        isPrimary: kaleidoscopeEnabled,
        isCompact: true,
        delay: const Duration(milliseconds: 180),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomParamsButton'),
        icon: Icons.casino_rounded,
        tooltip: l10n.randomize,
        onPressed: isExporting ? null : actions.randomizeParams,
        isCompact: true,
        delay: const Duration(milliseconds: 200),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomButton'),
        icon: Icons.shuffle_rounded,
        tooltip: l10n.tooltipRandomFractal,
        onPressed: isExporting ? null : actions.openRandomFractal,
        isPrimary: true,
        isCompact: true,
        delay: const Duration(milliseconds: 220),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerLooperButton'),
        icon: Icons.loop_rounded,
        tooltip: l10n.tooltipCameraLooper,
        onPressed: isExporting ? null : actions.openLooper,
        isCompact: true,
        delay: const Duration(milliseconds: 240),
      ),
      _ExportWallpaperFab(
        isExporting: isExporting,
        l10n: l10n,
        onOpenExport: actions.openExport,
        onShareImage: actions.shareImage,
        onOpenWallpaper: actions.openWallpaper,
      ),
    ];

    return FadeTransition(
      opacity: fabController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: fabController,
          curve: AppAnimations.defaultCurve,
        )),
        child: Align(
          alignment: Alignment.bottomRight,
          child: SingleChildScrollView(
            key: const ValueKey('viewerFabColumn'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in actionButtons) ...[
                  action,
                  const SizedBox(height: AppSpacing.sm),
                ],
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
  final VoidCallback onOpenWallpaper;

  const _ExportWallpaperFab({
    required this.isExporting,
    required this.l10n,
    required this.onOpenExport,
    required this.onShareImage,
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
        PopupMenuItem(
          key: const ValueKey('viewerShareMenuItem'),
          value: 'share',
          child: _MenuRow(
            icon: Icons.share_rounded,
            label: l10n.shareToSocialTargets,
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('viewerWallpaperMenuItem'),
          value: 'wallpaper',
          child: _MenuRow(
              icon: Icons.wallpaper_rounded, label: l10n.wallpaperTitle),
        ),
      ],
      child: Semantics(
        label: '${l10n.tooltipExport} / ${l10n.wallpaperTitle}',
        button: true,
        enabled: !isExporting,
        child: Tooltip(
          message: '${l10n.tooltipExport} / ${l10n.wallpaperTitle}',
          child: _FabMenuShell(
            icon: Icons.ios_share_rounded,
            enabled: !isExporting,
          ),
        ),
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
            behavior: HitTestBehavior.opaque,
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
            child: SizedBox.square(
              dimension:
                  widget.isCompact ? AccessibleSizing.minTouchTarget : 52,
              child: Center(
                child: reduceMotion
                    ? _buildButtonContent()
                    : ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildButtonContent(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final container = AnimatedContainer(
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

    // Buttons with a long-press secondary action are otherwise invisible. Mark
    // them with a small corner dot so the hidden affordance is discoverable.
    // The action itself stays in the semantics label ("Long press for ...").
    if (widget.onLongPress == null) return container;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        container,
        Positioned(
          top: 5,
          right: 5,
          child: IgnorePointer(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isPrimary
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.primary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
