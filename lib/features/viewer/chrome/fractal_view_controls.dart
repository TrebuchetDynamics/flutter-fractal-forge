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
  final VoidCallback? randomizePalette;
  final VoidCallback? previousFractal;
  final VoidCallback? openRandomCategories;
  final VoidCallback? pauseMotion;
  final VoidCallback toggleKaleidoscope;
  final ValueChanged<int> setKaleidoscopeSectors;
  final ValueChanged<bool> setKaleidoscopeMirror;
  final VoidCallback openExport;
  final VoidCallback shareLink;
  final VoidCallback shareImage;
  final VoidCallback toggleTextOverlay;
  final VoidCallback editTextOverlay;
  final VoidCallback openLooper;
  final VoidCallback toggleLooper;
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
    this.randomizePalette,
    this.previousFractal,
    this.openRandomCategories,
    this.pauseMotion,
    required this.toggleKaleidoscope,
    required this.setKaleidoscopeSectors,
    required this.setKaleidoscopeMirror,
    required this.openExport,
    required this.shareLink,
    required this.shareImage,
    required this.toggleTextOverlay,
    required this.editTextOverlay,
    required this.openLooper,
    required this.toggleLooper,
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
  final bool looperPlaying;
  final bool looperAvailable;
  final bool canGoPreviousFractal;
  final bool fourierEnabled;
  final bool textOverlayEnabled;
  final bool showFractalReport;
  final bool supportsAuxiliaryTools;
  final FractalViewControlActions actions;

  /// The short-screen shared scroll surface owns spacing, not OS safe insets.
  final bool compactViewport;

  const FractalViewControls({
    super.key,
    required this.fabController,
    required this.isExporting,
    required this.kaleidoscopeEnabled,
    required this.kaleidoscopeSectors,
    required this.kaleidoscopeMirror,
    required this.looperPlaying,
    this.looperAvailable = true,
    this.canGoPreviousFractal = false,
    required this.fourierEnabled,
    required this.textOverlayEnabled,
    this.showFractalReport = false,
    this.compactViewport = false,
    this.supportsAuxiliaryTools = true,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    // Keep the seven-icon rail on one row at common phone widths without
    // reducing the 48/56-pixel targets. Use generous margins on larger screens.
    final horizontalMargin =
        compactViewport ? 0.0 : (mq.size.width < 480 ? 8.0 : 16.0);
    final insets = EdgeInsets.fromLTRB(
      math.max(math.max(mq.padding.left, mq.viewPadding.left),
              mq.systemGestureInsets.left) +
          horizontalMargin,
      compactViewport ? 0 : 8,
      math.max(math.max(mq.padding.right, mq.viewPadding.right),
              mq.systemGestureInsets.right) +
          horizontalMargin,
      math.max(math.max(mq.padding.bottom, mq.viewPadding.bottom),
              mq.systemGestureInsets.bottom) +
          (compactViewport ? 0 : 16),
    );
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
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  key: const ValueKey('viewerFabColumn'),
                  // Transparent rail: each action is its own floating circle,
                  // not a modal-looking slab behind the controls.
                  color: Colors.transparent,
                  clipBehavior: Clip.none,
                  child: LayoutBuilder(builder: (context, constraints) {
                    final target = AccessibleSizing.touchTargetSize(
                        largeTargets: context
                                .watch<AccessibilityService?>()
                                ?.largeTargetsEnabled ??
                            false);
                    // Compact icon rail: more actions, no captions. Tooltips and
                    // semantics still carry the full localized names, and every
                    // visual cell keeps a full 48/56-pixel hit target.
                    final buttons = <_ViewerTool>[
                      _ViewerTool(
                        toolKey: const ValueKey('viewerPreviousFractalButton'),
                        icon: Icons.arrow_back_rounded,
                        label: l10n.hudPreviousFractal,
                        showLabel: false,
                        onPressed: isExporting || !canGoPreviousFractal
                            ? null
                            : actions.previousFractal,
                        sortOrder: 0,
                      ),
                      _ViewerTool(
                        // Play runs the camera looper; a long press edits it.
                        toolKey: const ValueKey('viewerPlayButton'),
                        icon: looperPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        label:
                            looperPlaying ? l10n.actionPause : l10n.actionPlay,
                        semanticLabel: looperPlaying
                            ? l10n.tooltipPauseLooper
                            : l10n.tooltipPlayLooper,
                        selected: looperPlaying,
                        showLabel: false,
                        onPressed: isExporting || !looperAvailable
                            ? null
                            : actions.toggleLooper,
                        onLongPress: isExporting ? null : actions.openLooper,
                        sortOrder: 1,
                      ),
                      _ViewerTool(
                        toolKey: const ValueKey('viewerControlsButton'),
                        icon: Icons.tune_rounded,
                        label: l10n.randomize,
                        semanticLabel: l10n.tooltipRandomizeWithControls,
                        showLabel: false,
                        onPressed: isExporting ? null : actions.randomizeParams,
                        onLongPress: isExporting ? null : actions.openControls,
                        sortOrder: 2,
                      ),
                      _ViewerTool(
                        toolKey: const ValueKey('viewerPaletteButton'),
                        icon: Icons.palette_outlined,
                        label: l10n.randomize,
                        semanticLabel: l10n.tooltipRandomizePaletteWithSettings,
                        showLabel: false,
                        onPressed: isExporting
                            ? null
                            : (actions.randomizePalette ??
                                actions.cycleColorScheme),
                        onLongPress:
                            isExporting ? null : actions.openPalettePicker,
                        sortOrder: 3,
                      ),
                      _ViewerTool(
                        toolKey: const ValueKey('viewerRandomFractalFab'),
                        icon: Icons.shuffle_rounded,
                        label: l10n.navDockRandom,
                        semanticLabel: l10n.tooltipRandomFractal,
                        showLabel: false,
                        onPressed:
                            isExporting ? null : actions.openRandomFractal,
                        onLongPress: isExporting
                            ? null
                            : (actions.openRandomCategories ??
                                () => _showRandomOptionsModal(context)),
                        sortOrder: 4,
                      ),
                      _ViewerTool(
                        // One primary entry point for the share/export actions;
                        // they no longer hide inside the More sheet.
                        toolKey: const ValueKey('viewerSaveShareButton'),
                        icon: Icons.ios_share_rounded,
                        label: l10n.viewerActionSectionSaveShare,
                        semanticLabel: l10n.viewerActionSectionSaveShare,
                        showLabel: false,
                        sortOrder: 5,
                        onPressed:
                            isExporting ? null : () => _showSaveShare(context),
                      ),
                      _ViewerTool(
                        toolKey: const ValueKey('viewerOverflowMenu'),
                        icon: Icons.more_horiz_rounded,
                        label: l10n.viewerMoreTools,
                        showLabel: false,
                        sortOrder: 6,
                        onPressed:
                            isExporting ? null : () => _showMore(context),
                      ),
                    ];
                    final availableWidth =
                        constraints.maxWidth - 8; // 4px inset each side
                    final perRow =
                        math.max(1, (availableWidth / target).floor());
                    final rowCount =
                        math.max(1, (buttons.length / perRow).ceil());
                    final base = buttons.length ~/ rowCount;
                    final extra = buttons.length % rowCount;
                    final rows = <Widget>[];
                    var next = 0;
                    for (var row = 0; row < rowCount; row++) {
                      final count = base + (row < extra ? 1 : 0);
                      final rowButtons = buttons.sublist(next, next + count);
                      next += count;
                      rows.add(Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final button in rowButtons)
                            SizedBox(
                              key: button.toolKey ==
                                      const ValueKey('viewerSaveShareButton')
                                  ? const ValueKey('viewerExportButton')
                                  : null,
                              width: target,
                              height: target,
                              child: button,
                            )
                        ],
                      ));
                    }
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: FocusTraversalGroup(
                          policy: OrderedTraversalPolicy(),
                          child: Column(children: rows),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Save/export actions live behind one primary button instead of a section
  /// buried in the More sheet.
  void _showSaveShare(BuildContext context) {
    actions.pauseMotion?.call();
    final l10n = AppLocalizations.of(context)!;
    final short = MediaQuery.of(context).textScaler.scale(14) > 14;
    showAppBottomSheet<VoidCallback>(
      context: context,
      builder: (sheetContext) {
        Widget row(String key, IconData icon, String label, VoidCallback action,
                {String? caption, int order = 0}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ViewerTool(
                toolKey: ValueKey(key),
                icon: icon,
                label: caption ?? label,
                semanticLabel: label,
                row: true,
                dense: short,
                sortOrder: order.toDouble(),
                onPressed: isExporting
                    ? null
                    : () => Navigator.of(sheetContext).pop(action),
              ),
            );
        return AppOptionsSheet(
          icon: Icons.ios_share_rounded,
          title: l10n.viewerActionSectionSaveShare,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              row('viewerOpenExportAction', Icons.file_download_outlined,
                  l10n.tooltipExport, actions.openExport),
              row('viewerShareLinkAction', Icons.link_rounded,
                  l10n.shareLinkAction, actions.shareLink,
                  caption: short ? l10n.viewerCopyLinkAction : null, order: 1),
              row('viewerShareImageAction', Icons.image_outlined,
                  l10n.tooltipShareImage, actions.shareImage, order: 2),
              if (ExportActionAvailability.canSetWallpaper(
                  isWeb: kIsWeb, platform: defaultTargetPlatform))
                row('viewerWallpaperAction', Icons.wallpaper_rounded,
                    l10n.wallpaperTitle, actions.openWallpaper, order: 3),
            ],
          ),
        );
      },
    ).then((action) {
      // Use the still-mounted viewer context, never the dismissed sheet route.
      if (context.mounted) action?.call();
    });
  }

  void _showMore(BuildContext context) {
    // Opening the menu freezes the scene so its rows act on what the user saw.
    actions.pauseMotion?.call();
    final l10n = AppLocalizations.of(context)!;
    final contextForOptions = context;
    // The viewer-scoped service is below the Navigator, not above its route.
    final explore = context.read<AutoExploreService?>();
    showAppBottomSheet<VoidCallback>(
      context: context,
      builder: (sheetContext) => LayoutBuilder(builder: (context, constraints) {
        final media = MediaQuery.of(context);
        double safe(double padding, double viewPadding, double gesture) =>
            math.max(math.max(padding, viewPadding), gesture);
        final insets = EdgeInsets.fromLTRB(
          safe(media.padding.left, media.viewPadding.left,
              media.systemGestureInsets.left),
          0,
          safe(media.padding.right, media.viewPadding.right,
              media.systemGestureInsets.right),
          safe(media.padding.bottom, media.viewPadding.bottom,
                  media.systemGestureInsets.bottom) +
              media.viewInsets.bottom,
        );
        // Use concise, contextual captions in tiny viewports; complete action
        // names and state remain in tooltips/semantics. Never shrink text.
        final tiny = constraints.maxHeight - insets.bottom < 240;
        final short = tiny || media.textScaler.scale(14) > 14;
        return ChangeNotifierProvider<AutoExploreService?>.value(
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
            Widget section(String label) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: Semantics(
                      header: true,
                      child: Text(label,
                          style: Theme.of(context).textTheme.titleSmall)),
                );
            Widget row(
                String key, IconData icon, String label, VoidCallback action,
                {VoidCallback? options,
                String? settingsLabel,
                String? settingsCaption,
                VoidCallback? onLongPress,
                bool? selected,
                bool enabled = true,
                String? hint,
                String? caption}) {
              final order = rowOrder++;
              VoidCallback closeThen(VoidCallback callback) =>
                  () => Navigator.of(sheetContext).pop(callback);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ViewerTool(
                      toolKey: ValueKey(key),
                      icon: icon,
                      label: caption ?? label,
                      semanticLabel: label,
                      row: true,
                      dense: short,
                      sortOrder: order,
                      selected: selected,
                      semanticHint: hint,
                      onPressed:
                          isExporting || !enabled ? null : closeThen(action),
                      onLongPress: isExporting ||
                              !enabled ||
                              (onLongPress ?? options) == null
                          ? null
                          : closeThen((onLongPress ?? options)!),
                    ),
                    if (options != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: _ViewerTool(
                          toolKey: ValueKey('${key}Options'),
                          sortOrder: order + 0.5,
                          icon: Icons.settings_outlined,
                          label: settingsCaption ?? settingsLabel!,
                          semanticLabel: settingsLabel,
                          row: true,
                          dense: short,
                          onPressed: isExporting ? null : closeThen(options),
                        ),
                      ),
                  ],
                ),
              );
            }

            final content = FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    section(l10n.viewerActionSectionExploreAnimate),
                    row(
                      'viewerRandomOptionsAction',
                      Icons.shuffle_rounded,
                      l10n.randomOptionsTitle,
                      () => _showRandomOptionsModal(contextForOptions),
                      caption:
                          tiny ? l10n.viewerActionSettingsRandomCompact : null,
                    ),
                    row(
                        'viewerRandomParamsButton',
                        Icons.tune_rounded,
                        l10n.tooltipRandomizeWithControls,
                        actions.randomizeParams,
                        caption: l10n.randomize,
                        options: actions.openControls,
                        settingsLabel: l10n.viewerActionSettingsControls,
                        settingsCaption: tiny ? l10n.controlsTitle : null),
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
                            settingsLabel: l10n.viewerActionSettingsExplore,
                            settingsCaption: tiny
                                ? l10n.viewerActionSettingsExploreCompact
                                : null,
                            selected: status.isMotionActive,
                            caption: short ? l10n.tabExplore : null),
                      ],
                    ],
                    section(l10n.viewerActionSectionVisualEffects),
                    row(
                        'viewerColorCycleButton',
                        Icons.palette_rounded,
                        l10n.viewerActionSettingsCyclePalette,
                        actions.cycleColorScheme,
                        caption: tiny
                            ? l10n.viewerActionSettingsCyclePaletteCompact
                            : null,
                        options: actions.openPalettePicker,
                        settingsLabel: l10n.viewerActionSettingsPalette,
                        settingsCaption: tiny
                            ? l10n.viewerActionSettingsPaletteCompact
                            : null),
                    if (supportsAuxiliaryTools) ...[
                      row(
                          'viewerKaleidoscopeFab',
                          Icons.filter_vintage_rounded,
                          kaleidoscopeEnabled
                              ? l10n.tooltipKaleidoscopeOn
                              : l10n.tooltipKaleidoscopeOff,
                          actions.toggleKaleidoscope,
                          selected: kaleidoscopeEnabled,
                          caption: short ? l10n.hudKaleidoscope : null,
                          options: () =>
                              _showKaleidoscopeModal(contextForOptions),
                          settingsLabel: l10n.viewerActionSettingsKaleidoscope,
                          settingsCaption:
                              tiny ? l10n.kaleidoscopeSectors : null),
                      row(
                          'viewerFourierFab',
                          Icons.blur_on_rounded,
                          fourierEnabled
                              ? l10n.tooltipFourierOn
                              : l10n.tooltipFourierOff,
                          actions.toggleFourier,
                          selected: fourierEnabled,
                          caption: tiny
                              ? l10n.viewerActionSettingsFourierCompactTitle
                              : (short ? l10n.fourierSettingsTitle : null),
                          options: actions.openFourierSettings,
                          settingsLabel: l10n.viewerActionSettingsFourier,
                          settingsCaption: tiny
                              ? l10n.viewerActionSettingsFourierCompact
                              : null,
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
                          caption: tiny
                              ? l10n.viewerActionSettingsTextCompactTitle
                              : (short ? l10n.textOverlayTitle : null),
                          options: actions.editTextOverlay,
                          settingsLabel: l10n.viewerActionSettingsText,
                          settingsCaption: tiny
                              ? l10n.viewerActionSettingsTextCompact
                              : null),
                    ],
                    section(l10n.viewerActionSectionViewReport),
                    row('viewerFullscreenButton', Icons.fullscreen_rounded,
                        l10n.tooltipFullscreen, actions.toggleFullscreen),
                    if (showFractalReport)
                      row(
                          'viewerReportFractalFab',
                          Icons.report_problem_outlined,
                          l10n.tooltipReportFractal,
                          actions.reportFractal,
                          caption: tiny
                              ? l10n.viewerActionSettingsReportCompact
                              : null),
                  ]),
            );
            // Scroll the shared header with content: even a short viewport at
            // 3x text must leave every action and the close target reachable.
            return AppBottomSheet(
              maxHeightFactor: 0.78,
              children: [
                Flexible(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: insets.left, right: insets.right),
                    child: SingleChildScrollView(
                      key: const ValueKey('viewerShortMoreViewport'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBottomSheetHeader(
                            icon: Icons.more_horiz_rounded,
                            title: l10n.viewerActionsMenu,
                            onClose: () => Navigator.of(sheetContext).pop(),
                          ),
                          const Divider(height: 1),
                          Padding(
                              padding: const EdgeInsets.all(8), child: content),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }),
    ).then((action) {
      // Use the still-mounted viewer context, never the dismissed sheet route,
      // when opening a follow-up options sheet.
      if (context.mounted) action?.call();
    });
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
  final bool dense;
  final bool showLabel;
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
      this.dense = false,
      this.showLabel = true,
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
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: colors.onSurface, height: widget.dense ? 1.1 : null));
    // A row keeps the full width tappable but paints the circle on the leading
    // edge; drawing the icon and the circle again in the label area duplicated
    // both and left a stray circle across the text.
    final visual = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.dense ? 0 : 8, vertical: widget.dense ? 0 : 8),
      child: !widget.showLabel
          ? Center(
              child:
                  Icon(widget.icon, size: 20, color: colors.onSurfaceVariant))
          : widget.row
              ? Row(children: [
                  // A dense row is text-only so a 3x label keeps the space it
                  // needs inside a short viewport.
                  if (!widget.dense) SizedBox(width: target + 12),
                  if (widget.dense && widget.selected != null) ...[
                    Icon(
                        widget.selected!
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank,
                        size: 20),
                    const SizedBox(width: 4),
                  ],
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
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Opacity(
              // Dense rows keep the full-width hit area and semantics but paint
              // no circular surface; the label alone carries the row.
              opacity: widget.row && widget.dense ? 0 : 1,
              alwaysIncludeSemantics: true,
              child: FloatingActionButtonWidget(
                key: widget.toolKey,
                icon: widget.icon,
                tooltip: widget.semanticLabel ?? widget.label,
                semanticHint: widget.semanticHint,
                onPressed: widget.onPressed,
                onLongPress: widget.onLongPress,
                selected: widget.selected,
                sortOrder: widget.sortOrder,
                surfaceAlignment: widget.row
                    ? AlignmentDirectional.centerStart
                    : Alignment.center,
              ),
            ),
          ),
          IgnorePointer(
              child: ExcludeSemantics(
                  child: Container(
            constraints: BoxConstraints(minWidth: target, minHeight: target),
            decoration: widget.row
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.selected == true
                        ? colors.onSurface.withValues(alpha: 0.10)
                        : null,
                    border: _focused
                        ? Border.all(
                            color: HighContrastColors.focusIndicator,
                            width: AccessibleSizing.focusIndicatorWidth)
                        : null,
                  )
                : BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.selected == true
                        ? Color.alphaBlend(
                            colors.onSurface.withValues(alpha: 0.12),
                            colors.surface.withValues(alpha: 0.94))
                        : colors.surface.withValues(alpha: 0.94),
                    border: Border.all(
                        color: _focused
                            ? HighContrastColors.focusIndicator
                            : colors.outlineVariant.withValues(alpha: 0.55),
                        width: _focused
                            ? AccessibleSizing.focusIndicatorWidth
                            : 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
    super.surfaceAlignment,
  });
}
