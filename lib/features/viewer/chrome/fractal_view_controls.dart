import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';

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
  final bool supportsAuxiliaryTools;
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
    this.supportsAuxiliaryTools = true,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final insets = EdgeInsets.fromLTRB(
      math.max(mq.viewPadding.left, mq.systemGestureInsets.left) + 16,
      8,
      math.max(mq.viewPadding.right, mq.systemGestureInsets.right) + 16,
      math.max(mq.viewPadding.bottom, mq.systemGestureInsets.bottom) + 16,
    );
    final buttons = <Widget>[
      _ViewerTool(
        toolKey: const ValueKey('viewerControlsButton'),
        icon: Icons.tune_rounded,
        label: l10n.controlsTitle,
        onPressed: isExporting ? null : actions.openControls,
        sortOrder: 0,
      ),
      _ViewerTool(
        toolKey: const ValueKey('viewerPaletteButton'),
        icon: Icons.palette_outlined,
        label: l10n.hudPalette,
        onPressed: isExporting ? null : actions.openPalettePicker,
        sortOrder: 1,
      ),
      _ViewerTool(
        toolKey: const ValueKey('viewerRandomFractalFab'),
        icon: Icons.shuffle_rounded,
        label: l10n.navDockRandom,
        onPressed: isExporting ? null : actions.openRandomFractal,
        onLongPress:
            isExporting ? null : () => _showRandomOptionsModal(context),
        sortOrder: 2,
      ),
      SizedBox(
        key: const ValueKey('viewerExportButton'),
        child: _ViewerTool(
          toolKey: const ValueKey('viewerOverflowMenu'),
          icon: Icons.more_horiz_rounded,
          label: l10n.viewerMoreTools,
          onPressed: isExporting ? null : () => _showMore(context),
          sortOrder: 3,
        ),
      ),
    ];
    return FadeTransition(
      opacity: fabController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: fabController, curve: AppAnimations.defaultCurve)),
        child: Padding(
          padding: insets,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Material(
                key: const ValueKey('viewerFabColumn'),
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(builder: (context, constraints) {
                  final innerWidth = constraints.maxWidth - 16;
                  final columns =
                      innerWidth >= 280 && mq.textScaler.scale(14) < 21 ? 4 : 2;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Wrap(
                          children: [
                            for (final button in buttons)
                              SizedBox(
                                  width: innerWidth / columns, child: button)
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMore(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contextForOptions = context;
    // The viewer-scoped service is below the Navigator, not above its route.
    final explore = context.read<AutoExploreService?>();
    showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) =>
          ChangeNotifierProvider<AutoExploreService?>.value(
        value: explore,
        child: Builder(builder: (context) {
          final service = context.watch<AutoExploreService?>();
          final status = service == null
              ? null
              : AutoExploreControlStatus.fromPlayback(
                  isExploring: service.isExploring,
                  isPaused: service.isPaused,
                  pausedByUserCorrection: service.pausedByUserCorrection,
                );
          var rowOrder = 0.0;
          Widget row(
              String key, IconData icon, String label, VoidCallback action,
              {VoidCallback? options,
              bool? selected,
              String? hint,
              String? caption}) {
            final order = rowOrder++;
            VoidCallback closeThen(VoidCallback callback) => () {
                  Navigator.of(sheetContext).pop();
                  callback();
                };
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LayoutBuilder(builder: (context, constraints) {
                final stacked = constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) >= 21;
                final primary = _ViewerTool(
                  toolKey: ValueKey(key),
                  icon: icon,
                  label: caption ?? label,
                  semanticLabel: label,
                  row: true,
                  sortOrder: order,
                  selected: selected,
                  semanticHint: hint,
                  onPressed: isExporting ? null : closeThen(action),
                  onLongPress: isExporting || options == null
                      ? null
                      : closeThen(options),
                );
                final secondary = options == null
                    ? null
                    : _ViewerTool(
                        toolKey: ValueKey('${key}Options'),
                        sortOrder: order + 0.5,
                        icon: Icons.settings_outlined,
                        label: l10n.viewerToolOptions,
                        semanticLabel: '$label: ${l10n.viewerToolOptions}',
                        row: stacked,
                        onPressed: isExporting ? null : closeThen(options),
                      );
                if (stacked) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [primary, if (secondary != null) secondary]);
                }
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: primary),
                      if (secondary != null)
                        Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: secondary)
                    ]);
              }),
            );
          }

          return AppOptionsSheet(
            icon: Icons.more_horiz_rounded,
            title: l10n.viewerActionsMenu,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    row('viewerOpenExportAction', Icons.file_download_outlined,
                        l10n.tooltipExport, actions.openExport),
                    row('viewerShareLinkAction', Icons.link_rounded,
                        l10n.shareLinkAction, actions.shareLink),
                    row('viewerShareImageAction', Icons.image_outlined,
                        l10n.tooltipShareImage, actions.shareImage),
                    if (ExportActionAvailability.canSetWallpaper(
                        isWeb: kIsWeb, platform: defaultTargetPlatform))
                      row('viewerWallpaperAction', Icons.wallpaper_rounded,
                          l10n.wallpaperTitle, actions.openWallpaper),
                    row(
                      'viewerRandomOptionsAction',
                      Icons.shuffle_rounded,
                      l10n.randomOptionsTitle,
                      () => _showRandomOptionsModal(contextForOptions),
                    ),
                    row(
                        'viewerRandomParamsButton',
                        Icons.tune_rounded,
                        l10n.tooltipRandomizeWithControls,
                        actions.randomizeParams,
                        caption: l10n.randomize,
                        options: actions.openControls),
                    row(
                        'viewerColorCycleButton',
                        Icons.palette_rounded,
                        l10n.tooltipColorSchemeWithPalette,
                        actions.cycleColorScheme,
                        caption: l10n.paramColorScheme,
                        options: actions.openPalettePicker),
                    if (supportsAuxiliaryTools) ...[
                      if (service != null && status != null) ...[
                        if (status.showsYieldBadge)
                          Text(l10n.autoExplorePausedUserCorrection),
                        row(
                            'viewerAutoExploreButton',
                            status.isMotionActive
                                ? Icons.pause_rounded
                                : Icons.explore_rounded,
                            status.primaryActionLabel(
                                startLabel: l10n.tooltipStartExplore,
                                pauseLabel: l10n.tooltipPauseExplore,
                                resumeLabel: l10n.actionResume), () {
                          if (status.resumesFromTemporaryYield) {
                            service.resume();
                          } else {
                            service.toggle();
                          }
                        },
                            options: actions.openAutoExploreSettings,
                            selected: status.isMotionActive),
                      ],
                      row('viewerLooperFab', Icons.loop_rounded,
                          l10n.tooltipCameraLooper, actions.openLooper),
                      row(
                          'viewerKaleidoscopeFab',
                          Icons.filter_vintage_rounded,
                          kaleidoscopeEnabled
                              ? l10n.tooltipKaleidoscopeOn
                              : l10n.tooltipKaleidoscopeOff,
                          actions.toggleKaleidoscope,
                          selected: kaleidoscopeEnabled,
                          options: () =>
                              _showKaleidoscopeModal(contextForOptions)),
                      row(
                          'viewerFourierFab',
                          Icons.blur_on_rounded,
                          fourierEnabled
                              ? l10n.tooltipFourierOn
                              : l10n.tooltipFourierOff,
                          actions.toggleFourier,
                          selected: fourierEnabled,
                          options: actions.openFourierSettings,
                          hint:
                              '${l10n.fourierOptionsDescription} ${l10n.viewerSecondaryActionHint}'),
                      row(
                          'viewerTextOverlayFab',
                          Icons.format_quote_rounded,
                          textOverlayEnabled
                              ? l10n.tooltipTextOverlayOn
                              : l10n.tooltipTextOverlayOff,
                          actions.toggleTextOverlay,
                          selected: textOverlayEnabled,
                          options: actions.editTextOverlay),
                      row(
                          'viewerFractalMusicFab',
                          Icons.music_note,
                          fractalMusicEnabled
                              ? l10n.tooltipFractalMusicOn
                              : l10n.tooltipFractalMusicOff,
                          actions.toggleFractalMusic,
                          selected: fractalMusicEnabled),
                    ],
                    row('viewerFullscreenButton', Icons.fullscreen_rounded,
                        l10n.tooltipFullscreen, actions.toggleFullscreen),
                    if (showFractalReport)
                      row(
                          'viewerReportFractalFab',
                          Icons.report_problem_outlined,
                          l10n.tooltipReportFractal,
                          actions.reportFractal),
                  ]),
            ),
          );
        }),
      ),
    );
  }

  void _showRandomOptionsModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => AppOptionsSheet(
        icon: Icons.shuffle_rounded,
        title: l10n.randomOptionsTitle,
        subtitle: l10n.randomOptionsSubtitle,
        child: Column(
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
        ),
      ),
    );
  }

  void _showKaleidoscopeModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var selectedSectors = kaleidoscopeSectors;
    var mirrorEnabled = kaleidoscopeMirror;
    showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => AppOptionsSheet(
          icon: Icons.filter_vintage_rounded,
          title: l10n.kaleidoscopeOptionsTitle,
          subtitle: l10n.kaleidoscopeOptionsSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      mainAxisExtent: AccessibleSizing.touchTargetSize(
                          largeTargets: context
                                  .watch<AccessibilityService?>()
                                  ?.largeTargetsEnabled ??
                              false),
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
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.flip_rounded),
                title: Text(l10n.kaleidoscopeMirrorWedges),
                subtitle: Text(l10n.kaleidoscopeMirrorWedgesDescription),
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
      ),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          minTileHeight: 72,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          leading: Icon(icon),
          title: Text(label),
          subtitle: description == null ? null : Text(description!),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
        ),
      );
}

/// Keep all input, haptics and semantics on AppToolButton. The caption is a
/// paint-only layer over the same hit region, never a second tap handler.
class _ViewerTool extends StatefulWidget {
  final Key toolKey;
  final IconData icon;
  final String label;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool row;
  final bool? selected;
  final double? sortOrder;

  const _ViewerTool(
      {required this.toolKey,
      required this.icon,
      required this.label,
      this.semanticLabel,
      this.semanticHint,
      this.onPressed,
      this.onLongPress,
      this.row = false,
      this.selected,
      this.sortOrder});

  @override
  State<_ViewerTool> createState() => _ViewerToolState();
}

class _ViewerToolState extends State<_ViewerTool> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final target = AccessibleSizing.touchTargetSize(
        largeTargets:
            context.watch<AccessibilityService?>()?.largeTargetsEnabled ??
                false);
    final disabled = widget.onPressed == null && widget.onLongPress == null;
    final caption = Text(widget.label,
        textAlign: widget.row ? TextAlign.start : TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: colors.onSurface));
    final visual = Padding(
      padding: const EdgeInsets.all(8),
      child: widget.row
          ? Row(children: [
              Icon(widget.icon, size: 20),
              const SizedBox(width: 12),
              Expanded(child: caption)
            ])
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, size: 20),
              const SizedBox(height: 4),
              caption
            ]),
    );
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: Stack(
        children: [
          Positioned.fill(
              child: FloatingActionButtonWidget(
            key: widget.toolKey,
            icon: widget.icon,
            tooltip: widget.semanticLabel ?? widget.label,
            semanticHint: widget.semanticHint,
            onPressed: widget.onPressed,
            onLongPress: widget.onLongPress,
            selected: widget.selected,
            sortOrder: widget.sortOrder,
          )),
          IgnorePointer(
              child: ExcludeSemantics(
                  child: Container(
            constraints: BoxConstraints(minWidth: target, minHeight: target),
            decoration: BoxDecoration(
              color: widget.selected == true
                  ? Color.alphaBlend(
                      colors.onSurface.withValues(alpha: 0.12), colors.surface)
                  : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _focused
                      ? HighContrastColors.focusIndicator
                      : Colors.transparent,
                  width: AccessibleSizing.focusIndicatorWidth),
            ),
            child: Opacity(opacity: disabled ? 0.38 : 1, child: visual),
          ))),
        ],
      ),
    );
  }
}

/// Compatibility name for viewer callers; input and painting are shared.
class FloatingActionButtonWidget extends AppToolButton {
  final bool isCompact;

  const FloatingActionButtonWidget({
    super.key,
    required super.icon,
    required super.tooltip,
    super.semanticHint,
    super.onPressed,
    super.onLongPress,
    super.isPrimary,
    this.isCompact = false,
    super.selected,
    super.delay,
    super.sortOrder,
  });
}
