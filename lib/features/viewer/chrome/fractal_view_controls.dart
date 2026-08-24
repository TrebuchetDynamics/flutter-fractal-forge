import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
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
  final VoidCallback toggleFourier;
  final VoidCallback openFourierSettings;
  final VoidCallback reportFractal;
  final VoidCallback openWallpaper;
  final VoidCallback? openAutoExploreSettings;

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
    required this.toggleFourier,
    required this.openFourierSettings,
    required this.reportFractal,
    required this.openWallpaper,
    this.openAutoExploreSettings,
  });
}

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final bool isExporting;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final bool fractalMusicEnabled;
  final bool fourierEnabled;
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
    required this.fourierEnabled,
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
      // Auto-explore lives in the FAB column with the other quick actions so
      // the primary play/pause control is reachable from the same cluster. It
      // renders as a no-op (SizedBox.shrink) when no AutoExploreService is
      // provided, so hosts without the feature keep the previous button count.
      AutoExploreButton(
        key: const ValueKey('viewerAutoExploreButton'),
        onLongPress: actions.openAutoExploreSettings,
        delay: const Duration(milliseconds: 40),
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomParamsButton'),
        icon: Icons.tune_rounded,
        tooltip: l10n.tooltipRandomizeWithControls,
        onPressed: isExporting ? null : actions.randomizeParams,
        onLongPress: isExporting ? null : actions.openControls,
        isCompact: true,
        delay: const Duration(milliseconds: 60),
        sortOrder: 1,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerColorCycleButton'),
        icon: Icons.palette_rounded,
        tooltip: l10n.tooltipColorSchemeWithPalette,
        onPressed: isExporting ? null : actions.cycleColorScheme,
        onLongPress: isExporting ? null : actions.openPalettePicker,
        isCompact: true,
        delay: const Duration(milliseconds: 80),
        sortOrder: 2,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomFractalFab'),
        icon: Icons.shuffle_rounded,
        tooltip: l10n.tooltipRandomFractal,
        onPressed: isExporting ? null : actions.openRandomFractal,
        onLongPress:
            isExporting ? null : () => _showRandomOptionsModal(context),
        isCompact: true,
        delay: const Duration(milliseconds: 100),
        sortOrder: 3,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerLooperFab'),
        icon: Icons.loop_rounded,
        tooltip: l10n.tooltipCameraLooper,
        onPressed: isExporting ? null : actions.openLooper,
        isCompact: true,
        delay: const Duration(milliseconds: 120),
        sortOrder: 4,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFractalMusicFab'),
        icon: Icons.music_note,
        tooltip: fractalMusicEnabled
            ? l10n.tooltipFractalMusicOn
            : l10n.tooltipFractalMusicOff,
        onPressed: isExporting ? null : actions.toggleFractalMusic,
        selected: fractalMusicEnabled,
        isCompact: true,
        delay: const Duration(milliseconds: 140),
        sortOrder: 5,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerKaleidoscopeFab'),
        icon: Icons.filter_vintage_rounded,
        tooltip: kaleidoscopeEnabled
            ? l10n.tooltipKaleidoscopeOn
            : l10n.tooltipKaleidoscopeOff,
        onPressed: isExporting ? null : actions.toggleKaleidoscope,
        selected: kaleidoscopeEnabled,
        onLongPress: isExporting ? null : () => _showKaleidoscopeModal(context),
        isCompact: true,
        delay: const Duration(milliseconds: 160),
        sortOrder: 6,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerTextOverlayFab'),
        icon: Icons.format_quote_rounded,
        tooltip: textOverlayEnabled
            ? l10n.tooltipTextOverlayOn
            : l10n.tooltipTextOverlayOff,
        onPressed: isExporting ? null : actions.toggleTextOverlay,
        selected: textOverlayEnabled,
        onLongPress: isExporting ? null : actions.editTextOverlay,
        isCompact: true,
        delay: const Duration(milliseconds: 180),
        sortOrder: 7,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFourierFab'),
        icon: Icons.blur_on_rounded,
        tooltip:
            fourierEnabled ? l10n.tooltipFourierOn : l10n.tooltipFourierOff,
        semanticHint:
            '${l10n.fourierOptionsDescription} ${l10n.viewerSecondaryActionHint}',
        onPressed: isExporting ? null : actions.toggleFourier,
        selected: fourierEnabled,
        onLongPress: isExporting ? null : actions.openFourierSettings,
        isCompact: true,
        delay: const Duration(milliseconds: 200),
        sortOrder: 8,
      ),
      _ExportWallpaperFab(
        isExporting: isExporting,
        l10n: l10n,
        onOpenActions: () => _showExportModal(
          context,
          l10n,
          supportsWallpaper: supportsWallpaper,
        ),
        onLongPress: () => _showExportModal(
          context,
          l10n,
          supportsWallpaper: supportsWallpaper,
        ),
        sortOrder: 9,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFullscreenButton'),
        icon: Icons.fullscreen_rounded,
        tooltip: l10n.tooltipFullscreen,
        onPressed: isExporting ? null : actions.toggleFullscreen,
        isCompact: true,
        delay: const Duration(milliseconds: 220),
        sortOrder: 10,
      ),
      if (showFractalReport)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerReportFractalFab'),
          icon: Icons.report_problem_rounded,
          tooltip: l10n.tooltipReportFractal,
          onPressed: isExporting ? null : actions.reportFractal,
          isCompact: true,
          delay: const Duration(milliseconds: 240),
          sortOrder: 11,
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
              // Landscape wraps the uniform 48px FABs into at most three rows.
              // Keep room for all rows plus their 8px gaps on short viewports.
              maxHeight: isLandscape ? 176 : maxFabColumnHeight,
              maxWidth: isLandscape ? maxFabRowWidth : 112,
            ),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
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
      ),
    );
  }

  void _showRandomOptionsModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _showActionModal(
      context,
      icon: Icons.shuffle_rounded,
      title: l10n.randomOptionsTitle,
      subtitle: l10n.randomOptionsSubtitle,
      children: [
        _ActionTile(
          icon: Icons.shuffle_rounded,
          label: l10n.tooltipRandomFractal,
          description: l10n.randomOptionsCatalogDescription,
          onTap: actions.openRandomFractal,
        ),
        _ActionTile(
          icon: Icons.tune_rounded,
          label: l10n.randomize,
          description: l10n.randomOptionsParamsDescription,
          onTap: actions.randomizeParams,
        ),
      ],
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
      title: l10n.shareExportTitle,
      subtitle: supportsWallpaper
          ? l10n.exportOptionsSubtitleWithWallpaper
          : l10n.exportOptionsSubtitle,
      children: [
        _ActionTile(
          icon: Icons.download_rounded,
          label: l10n.tooltipExport,
          description: l10n.exportOptionsExportDescription,
          onTap: actions.openExport,
        ),
        _ActionTile(
          icon: Icons.link_rounded,
          label: l10n.shareLinkAction,
          description: l10n.exportOptionsLinkDescription,
          onTap: actions.shareLink,
        ),
        _ActionTile(
          icon: Icons.share_rounded,
          label: l10n.tooltipShareImage,
          description: l10n.exportOptionsImageDescription,
          onTap: actions.shareImage,
        ),
        if (supportsWallpaper)
          _ActionTile(
            icon: Icons.wallpaper_rounded,
            label: l10n.wallpaperTitle,
            description: l10n.exportOptionsWallpaperDescription,
            onTap: actions.openWallpaper,
          ),
      ],
    );
  }

  void _showKaleidoscopeModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var selectedSectors = kaleidoscopeSectors;
    var mirrorEnabled = kaleidoscopeMirror;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => _FabOptionsSheet(
          icon: Icons.filter_vintage_rounded,
          title: l10n.kaleidoscopeOptionsTitle,
          subtitle: l10n.kaleidoscopeOptionsSubtitle,
          children: [
            Text(
              l10n.kaleidoscopeWedgeCount,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 560 ? 7 : 4;
                // gridDelegate form instead of GridView.count:
                // mainAxisExtent is not a GridView.count parameter on all
                // supported SDK versions.
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    mainAxisExtent: 48,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Every value FractalController.setKaleidoscopeSectors can
                    // hold: it clamps to 4..16 and snaps odd inputs down to even,
                    // so a gap here means an unselectable, unreachable-by-chip
                    // state rather than a missing shortcut.
                    for (final sectors in const [4, 6, 8, 10, 12, 14, 16])
                      ChoiceChip(
                        label: Text('$sectors'),
                        selected: selectedSectors == sectors,
                        showCheckmark: false,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.28),
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
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _SwitchActionTile(
              icon: Icons.flip_rounded,
              label: l10n.kaleidoscopeMirrorWedges,
              description: l10n.kaleidoscopeMirrorWedgesDescription,
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
    double maxHeightFactor = 0.78,
    double contentBottomPadding = AppSpacing.xxxl,
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
        maxHeightFactor: maxHeightFactor,
        contentBottomPadding: contentBottomPadding,
        children: children,
      ),
    );
  }
}

class _FabOptionsSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double maxHeightFactor;
  final double contentBottomPadding;
  final List<Widget> children;

  const _FabOptionsSheet({
    required this.icon,
    required this.title,
    this.subtitle,
    this.maxHeightFactor = 0.78,
    this.contentBottomPadding = AppSpacing.xxxl,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      maxHeightFactor: maxHeightFactor,
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
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              contentBottomPadding,
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
              padding: EdgeInsets.symmetric(
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
    // The row and its Switch are two separate interactive nodes otherwise: the
    // row carries the label but no on/off state, and the Switch carries the
    // state but no label, so a screen reader can never hear both together.
    return MergeSemantics(
      child: Material(
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
  final AppLocalizations l10n;
  final VoidCallback onOpenActions;
  final VoidCallback onLongPress;
  final double sortOrder;

  const _ExportWallpaperFab({
    required this.isExporting,
    required this.l10n,
    required this.onOpenActions,
    required this.onLongPress,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButtonWidget(
      key: const ValueKey('viewerExportButton'),
      icon: Icons.ios_share_rounded,
      tooltip: l10n.shareExportTitle,
      onPressed: isExporting ? null : onOpenActions,
      onLongPress: isExporting ? null : onLongPress,
      isCompact: true,
      delay: const Duration(milliseconds: 150),
      sortOrder: sortOrder,
    );
  }
}

class FloatingActionButtonWidget extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isPrimary;
  final bool isCompact;
  final bool? selected;
  final Duration delay;
  final double? sortOrder;

  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    required this.tooltip,
    this.semanticHint,
    this.onPressed,
    this.onLongPress,
    this.isPrimary = false,
    this.isCompact = false,
    this.selected,
    this.delay = Duration.zero,
    this.sortOrder,
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
    // Every FAB goes inert while an export runs. Without a visual cue the
    // column looks identical to its live state, so taps land on nothing with
    // no feedback at all (no press animation, no haptic, no action).
    final isDisabled = widget.onPressed == null && widget.onLongPress == null;
    final semanticHint = widget.semanticHint ??
        (widget.onLongPress == null
            ? null
            : AppLocalizations.of(context)!.viewerSecondaryActionHint);

    final button = FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      // Own the complete accessibility contract here. Excluding descendant
      // gesture semantics prevents a second, unlabelled focus stop and keeps
      // the localized secondary-action hint on the actionable node.
      child: MergeSemantics(
        child: Semantics(
          excludeSemantics: true,
          label: widget.tooltip,
          hint: semanticHint,
          sortKey: widget.sortOrder == null
              ? null
              : OrdinalSortKey(widget.sortOrder!),
          button: true,
          selected: widget.selected,
          enabled: widget.onPressed != null,
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          child: Tooltip(
            message: widget.tooltip,
            child: FocusableActionDetector(
              enabled: widget.onPressed != null || widget.onLongPress != null,
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
                    widget.onLongPress?.call();
                    return null;
                  },
                ),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: widget.onPressed != null
                    ? (_) {
                        // Reduced motion suppresses the press animation only.
                        // Haptics are a separate preference and the only
                        // non-visual confirmation that the tap registered.
                        HapticService.medium();
                        if (reduceMotion) return;
                        setState(() => _isPressed = true);
                        _controller.forward();
                      }
                    : null,
                onTapUp: widget.onPressed != null
                    ? (_) {
                        setState(() => _isPressed = false);
                        _controller.reverse();
                      }
                    : null,
                onTapCancel: widget.onPressed != null
                    ? () {
                        setState(() => _isPressed = false);
                        _controller.reverse();
                      }
                    : null,
                onTap: widget.onPressed,
                onLongPress: widget.onLongPress,
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
                      child: _buildDimmedIfDisabled(
                        isDisabled,
                        reduceMotion
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
        ),
      ),
    );
    final sortOrder = widget.sortOrder;
    if (sortOrder == null) return button;
    return FocusTraversalOrder(
      order: NumericFocusOrder(sortOrder),
      child: button,
    );
  }

  /// Material's standard 38% disabled opacity, applied only when the button
  /// has no action left so enabled buttons keep a compositing-free paint path.
  Widget _buildDimmedIfDisabled(bool isDisabled, Widget content) {
    if (!isDisabled) return content;
    return Opacity(opacity: 0.38, child: content);
  }

  Widget _buildButtonContent() {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: _fabVisualSize,
      height: _fabVisualSize,
      decoration: BoxDecoration(
        gradient: widget.isPrimary || widget.selected == true
            ? AppColors.primaryGradient
            : null,
        color: widget.isPrimary || widget.selected == true
            ? null
            : AppColors.surface.withValues(alpha: _isPressed ? 0.86 : 0.74),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isPrimary || widget.selected == true
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
        color: widget.isPrimary || widget.selected == true
            ? Colors.white
            : (_isPressed ? AppColors.primaryLight : AppColors.textPrimary),
      ),
    );
  }
}
