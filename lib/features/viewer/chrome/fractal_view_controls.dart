import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

const double _fabTouchSize = AccessibleSizing.minTouchTarget;
const double _fabVisualSize = 44;
const double _fabIconSize = 20;

class FractalViewControlActions {
  final VoidCallback toggleFullscreen;
  final VoidCallback openRandomFractal;
  final VoidCallback openControls;
  final VoidCallback randomizeParams;
  final VoidCallback cycleColorScheme;
  final VoidCallback openPalettePicker;
  final VoidCallback toggleKaleidoscope;
  final ValueChanged<int> setKaleidoscopeSectors;
  final ValueChanged<bool> setKaleidoscopeMirror;
  final VoidCallback openExport;
  final VoidCallback shareLink;
  final VoidCallback shareImage;
  final VoidCallback toggleTextOverlay;
  final VoidCallback editTextOverlay;
  final VoidCallback openLooper;
  final VoidCallback toggleFractalMusic;
  final VoidCallback reportFractal;
  final VoidCallback openWallpaper;

  const FractalViewControlActions({
    required this.toggleFullscreen,
    required this.openRandomFractal,
    required this.openControls,
    required this.randomizeParams,
    required this.cycleColorScheme,
    required this.openPalettePicker,
    required this.toggleKaleidoscope,
    required this.setKaleidoscopeSectors,
    required this.setKaleidoscopeMirror,
    required this.openExport,
    required this.shareLink,
    required this.shareImage,
    required this.toggleTextOverlay,
    required this.editTextOverlay,
    required this.openLooper,
    required this.toggleFractalMusic,
    required this.reportFractal,
    required this.openWallpaper,
  });
}

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final bool isExporting;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final bool fractalMusicEnabled;
  final bool textOverlayEnabled;
  final bool showFractalReport;
  final FractalViewControlActions actions;

  const FractalViewControls({
    super.key,
    required this.fabController,
    required this.isExporting,
    required this.kaleidoscopeEnabled,
    required this.kaleidoscopeSectors,
    required this.kaleidoscopeMirror,
    required this.fractalMusicEnabled,
    required this.textOverlayEnabled,
    this.showFractalReport = false,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxFabColumnHeight = (mediaQuery.size.height -
            mediaQuery.padding.top -
            mediaQuery.padding.bottom -
            AppSpacing.xxl)
        .clamp(0.0, double.infinity);
    final maxFabRowWidth = (mediaQuery.size.width -
            mediaQuery.padding.left -
            mediaQuery.padding.right -
            AppSpacing.xxl)
        .clamp(0.0, double.infinity);
    final supportsWallpaper = ExportActionAvailability.canSetWallpaper(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );

    final actionButtons = <Widget>[
      if (showFractalReport)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerReportFractalButton'),
          icon: Icons.report_problem_rounded,
          tooltip: 'Report fractal',
          onPressed: isExporting ? null : actions.reportFractal,
          onLongPress: isExporting ? null : actions.reportFractal,
          isCompact: true,
          delay: const Duration(milliseconds: 60),
        ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomButton'),
        icon: Icons.shuffle_rounded,
        tooltip: l10n.tooltipRandomFractal,
        onPressed: isExporting ? null : actions.openRandomFractal,
        onLongPress: isExporting
            ? null
            : () => _showActionModal(
                  context,
                  icon: Icons.shuffle_rounded,
                  title: 'Random options',
                  subtitle:
                      'Jump to a new fractal or keep this one and reshape its parameters.',
                  children: [
                    _ActionTile(
                      icon: Icons.shuffle_rounded,
                      label: l10n.tooltipRandomFractal,
                      description: 'Switch to another catalog entry.',
                      onTap: actions.openRandomFractal,
                    ),
                    _ActionTile(
                      icon: Icons.tune_rounded,
                      label: l10n.randomize,
                      description:
                          'Stay on this fractal and randomize its controls.',
                      onTap: actions.randomizeParams,
                    ),
                  ],
                ),
        isCompact: true,
        delay: const Duration(milliseconds: 80),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomParamsButton'),
        icon: Icons.tune_rounded,
        tooltip: l10n.tooltipRandomizeWithControls,
        onPressed: isExporting ? null : actions.randomizeParams,
        onLongPress: isExporting ? null : actions.openControls,
        isCompact: true,
        delay: const Duration(milliseconds: 100),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerColorCycleButton'),
        icon: Icons.palette_rounded,
        tooltip: l10n.tooltipColorSchemeWithPalette,
        onPressed: isExporting ? null : actions.cycleColorScheme,
        onLongPress: isExporting ? null : actions.openPalettePicker,
        isCompact: true,
        delay: const Duration(milliseconds: 120),
      ),
      _ExportWallpaperFab(
        isExporting: isExporting,
        supportsWallpaper: supportsWallpaper,
        l10n: l10n,
        onOpenExport: actions.openExport,
        onLongPress: () => _showExportModal(
          context,
          l10n,
          supportsWallpaper: supportsWallpaper,
        ),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerTextOverlayButton'),
        icon: Icons.format_quote_rounded,
        tooltip: textOverlayEnabled
            ? l10n.tooltipTextOverlayOn
            : l10n.tooltipTextOverlayOff,
        onPressed: isExporting ? null : actions.toggleTextOverlay,
        onLongPress: isExporting ? null : actions.editTextOverlay,
        isPrimary: textOverlayEnabled,
        isCompact: true,
        delay: const Duration(milliseconds: 170),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerLooperButton'),
        icon: Icons.loop_rounded,
        tooltip: l10n.tooltipCameraLooper,
        onPressed: isExporting ? null : actions.openLooper,
        onLongPress: isExporting
            ? null
            : () => _showActionModal(
                  context,
                  icon: Icons.loop_rounded,
                  title: l10n.tooltipCameraLooper,
                  subtitle: 'Record repeatable camera motion for exports.',
                  children: [
                    _ActionTile(
                      icon: Icons.loop_rounded,
                      label: l10n.tooltipCameraLooper,
                      description: 'Open the looper timeline and GIF controls.',
                      onTap: actions.openLooper,
                    ),
                  ],
                ),
        isCompact: true,
        delay: const Duration(milliseconds: 180),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerKaleidoscopeButton'),
        icon: Icons.filter_vintage_rounded,
        tooltip: kaleidoscopeEnabled
            ? l10n.tooltipKaleidoscopeOn
            : l10n.tooltipKaleidoscopeOff,
        onPressed: isExporting ? null : actions.toggleKaleidoscope,
        onLongPress: isExporting ? null : () => _showKaleidoscopeModal(context),
        isPrimary: kaleidoscopeEnabled,
        isCompact: true,
        delay: const Duration(milliseconds: 200),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFractalMusicButton'),
        icon: Icons.music_note,
        tooltip: fractalMusicEnabled
            ? l10n.tooltipFractalMusicOn
            : l10n.tooltipFractalMusicOff,
        onPressed: isExporting ? null : actions.toggleFractalMusic,
        onLongPress: isExporting
            ? null
            : () => _showActionModal(
                  context,
                  icon: Icons.music_note,
                  title: l10n.tooltipFractalMusicOff,
                  subtitle:
                      'Turn the current image into a visible scan and sound.',
                  children: [
                    _ActionTile(
                      icon: Icons.music_note,
                      label: fractalMusicEnabled
                          ? l10n.tooltipFractalMusicOn
                          : l10n.tooltipFractalMusicOff,
                      description:
                          'Toggle radial scan sonification for this view.',
                      onTap: actions.toggleFractalMusic,
                    ),
                  ],
                ),
        isPrimary: fractalMusicEnabled,
        isCompact: true,
        delay: const Duration(milliseconds: 220),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFullscreenButton'),
        icon: Icons.fullscreen_rounded,
        tooltip: l10n.tooltipFullscreen,
        onPressed: isExporting ? null : actions.toggleFullscreen,
        onLongPress: isExporting
            ? null
            : () => _showActionModal(
                  context,
                  icon: Icons.fullscreen_rounded,
                  title: l10n.tooltipFullscreen,
                  subtitle: 'Hide controls for a cleaner viewing surface.',
                  children: [
                    _ActionTile(
                      icon: Icons.fullscreen_rounded,
                      label: l10n.tooltipFullscreen,
                      description: 'Enter the unobtrusive viewer mode.',
                      onTap: actions.toggleFullscreen,
                    ),
                  ],
                ),
        isCompact: true,
        delay: const Duration(milliseconds: 240),
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
          alignment:
              isLandscape ? Alignment.bottomCenter : Alignment.bottomRight,
          child: ConstrainedBox(
            key: const ValueKey('viewerFabColumn'),
            constraints: BoxConstraints(
              maxHeight: isLandscape ? 112 : maxFabColumnHeight,
              maxWidth: isLandscape ? maxFabRowWidth : 112,
            ),
            child: Wrap(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actionButtons,
            ),
          ),
        ),
      ),
    );
  }

  void _showExportModal(
    BuildContext context,
    AppLocalizations l10n, {
    required bool supportsWallpaper,
  }) {
    _showActionModal(
      context,
      icon: Icons.ios_share_rounded,
      title: supportsWallpaper
          ? '${l10n.tooltipExport} / ${l10n.wallpaperTitle}'
          : l10n.tooltipExport,
      subtitle: supportsWallpaper
          ? 'Save, share, or fit the current render to your device.'
          : 'Save or share the current render.',
      children: [
        _ActionTile(
          icon: Icons.download_rounded,
          label: l10n.tooltipExport,
          description: 'Choose resolution and transparent-background options.',
          onTap: actions.openExport,
        ),
        _ActionTile(
          icon: Icons.link_rounded,
          label: l10n.tooltipShare,
          description: 'Copy a replayable link to this exact view.',
          onTap: actions.shareLink,
        ),
        _ActionTile(
          icon: Icons.share_rounded,
          label: l10n.shareToSocialTargets,
          description: 'Render an image and send it to installed apps.',
          onTap: actions.shareImage,
        ),
        if (supportsWallpaper)
          _ActionTile(
            icon: Icons.wallpaper_rounded,
            label: l10n.wallpaperTitle,
            description: 'Preview crops for phone wallpaper sizes.',
            onTap: actions.openWallpaper,
          ),
      ],
    );
  }

  void _showKaleidoscopeModal(BuildContext context) {
    var selectedSectors = kaleidoscopeSectors;
    var mirrorEnabled = kaleidoscopeMirror;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => _FabOptionsSheet(
          icon: Icons.filter_vintage_rounded,
          title: 'Kaleidoscope sections',
          subtitle: 'Pick a symmetry count and mirror behavior for this view.',
          children: [
            Text(
              'Wedge count',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final sectors in const [4, 6, 8, 10, 12, 16])
                  ChoiceChip(
                    label: Text('$sectors'),
                    selected: selectedSectors == sectors,
                    showCheckmark: false,
                    selectedColor: AppColors.primary.withValues(alpha: 0.28),
                    backgroundColor:
                        AppColors.surfaceVariant.withValues(alpha: 0.9),
                    side: BorderSide(
                      color: selectedSectors == sectors
                          ? AppColors.primaryLight
                          : AppColors.glassBorder,
                    ),
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: selectedSectors == sectors
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: selectedSectors == sectors
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      selectedSectors = sectors;
                      actions.setKaleidoscopeSectors(sectors);
                      setSheetState(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SwitchActionTile(
              icon: Icons.flip_rounded,
              label: 'Mirror wedges',
              description: 'Reflect each wedge for sharper radial symmetry.',
              value: mirrorEnabled,
              onChanged: (value) {
                mirrorEnabled = value;
                actions.setKaleidoscopeMirror(value);
                setSheetState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActionModal(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FabOptionsSheet(
        icon: icon,
        title: title,
        subtitle: subtitle,
        children: children,
      ),
    );
  }
}

class _FabOptionsSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _FabOptionsSheet({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      maxHeightFactor: 0.78,
      children: [
        AppBottomSheetHeader(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceVariant.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  _ModalIconBadge(icon: icon),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
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

class _SwitchActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _ModalIconBadge(icon: icon),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalIconBadge extends StatelessWidget {
  final IconData icon;

  const _ModalIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ExportWallpaperFab extends StatelessWidget {
  final bool isExporting;
  final bool supportsWallpaper;
  final AppLocalizations l10n;
  final VoidCallback onOpenExport;
  final VoidCallback onLongPress;

  const _ExportWallpaperFab({
    required this.isExporting,
    required this.supportsWallpaper,
    required this.l10n,
    required this.onOpenExport,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButtonWidget(
      key: const ValueKey('viewerExportButton'),
      icon: Icons.ios_share_rounded,
      tooltip: supportsWallpaper
          ? '${l10n.tooltipExport} / ${l10n.wallpaperTitle}'
          : l10n.tooltipExport,
      onPressed: isExporting ? null : onOpenExport,
      onLongPress: isExporting ? null : onLongPress,
      isCompact: true,
      delay: const Duration(milliseconds: 150),
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

/// Keyboard-only alternate activation for a [FloatingActionButtonWidget]'s
/// long-press secondary action (mirrors Shift+Click conventions).
class _LongPressActivateIntent extends Intent {
  const _LongPressActivateIntent();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isFocused = false;

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
    final effectiveLongPress = widget.onLongPress ??
        (widget.onPressed == null ? null : () => _showDefaultLongPressModal());

    return FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onPressed != null,
        onLongPress: effectiveLongPress,
        child: Tooltip(
          message: widget.tooltip,
          child: FocusableActionDetector(
            enabled: widget.onPressed != null || effectiveLongPress != null,
            onShowFocusHighlight: (focused) {
              if (_isFocused == focused) return;
              setState(() => _isFocused = focused);
            },
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.enter, shift: true):
                  _LongPressActivateIntent(),
            },
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed?.call();
                  return null;
                },
              ),
              _LongPressActivateIntent:
                  CallbackAction<_LongPressActivateIntent>(
                onInvoke: (_) {
                  effectiveLongPress?.call();
                  return null;
                },
              ),
            },
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
              onLongPress: effectiveLongPress,
              child: SizedBox.square(
                dimension: _fabTouchSize,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _isFocused
                            ? HighContrastColors.focusIndicator
                            : Colors.transparent,
                        width: AccessibleSizing.focusIndicatorWidth,
                      ),
                    ),
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
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: _fabVisualSize,
      height: _fabVisualSize,
      decoration: BoxDecoration(
        gradient: widget.isPrimary ? AppColors.primaryGradient : null,
        color: widget.isPrimary
            ? null
            : AppColors.surface.withValues(alpha: _isPressed ? 0.86 : 0.74),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isPrimary
              ? Colors.white.withValues(alpha: 0.22)
              : (_isPressed
                  ? AppColors.primaryLight.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.14)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isPressed ? 0.28 : 0.18),
            blurRadius: _isPressed ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: _fabIconSize,
        color: widget.isPrimary
            ? Colors.white
            : (_isPressed ? AppColors.primaryLight : AppColors.textPrimary),
      ),
    );
  }

  void _showDefaultLongPressModal() {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FabOptionsSheet(
        icon: widget.icon,
        title: widget.tooltip,
        subtitle: 'Available action for this viewer control.',
        children: [
          _ActionTile(
            icon: widget.icon,
            label: widget.tooltip,
            description: 'Run this action and return to the viewer.',
            onTap: onPressed,
          ),
        ],
      ),
    );
  }
}
