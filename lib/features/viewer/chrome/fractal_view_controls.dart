import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/circular_tool_surface.dart';
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
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomParamsButton'),
        icon: Icons.tune_rounded,
        tooltip: l10n.tooltipRandomizeWithControls,
        onPressed: isExporting ? null : actions.randomizeParams,
        onLongPress: isExporting ? null : actions.openControls,
        isCompact: true,
        delay: const Duration(milliseconds: 40),
        sortOrder: 0,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerColorCycleButton'),
        icon: Icons.palette_rounded,
        tooltip: l10n.tooltipColorSchemeWithPalette,
        onPressed: isExporting ? null : actions.cycleColorScheme,
        onLongPress: isExporting ? null : actions.openPalettePicker,
        isCompact: true,
        delay: const Duration(milliseconds: 60),
        sortOrder: 1,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerRandomFractalFab'),
        icon: Icons.shuffle_rounded,
        tooltip: l10n.tooltipRandomFractal,
        onPressed: isExporting ? null : actions.openRandomFractal,
        onLongPress:
            isExporting ? null : () => _showRandomOptionsModal(context),
        isCompact: true,
        delay: const Duration(milliseconds: 80),
        sortOrder: 2,
      ),
      if (supportsAuxiliaryTools)
        AutoExploreButton(
          key: const ValueKey('viewerAutoExploreButton'),
          sortOrder: 3,
          onLongPress: actions.openAutoExploreSettings,
          delay: const Duration(milliseconds: 100),
        ),
      if (supportsAuxiliaryTools)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerLooperFab'),
          icon: Icons.loop_rounded,
          tooltip: l10n.tooltipCameraLooper,
          onPressed: isExporting ? null : actions.openLooper,
          isCompact: true,
          delay: const Duration(milliseconds: 120),
          sortOrder: 4,
        ),
      if (supportsAuxiliaryTools)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerKaleidoscopeFab'),
          icon: Icons.filter_vintage_rounded,
          tooltip: kaleidoscopeEnabled
              ? l10n.tooltipKaleidoscopeOn
              : l10n.tooltipKaleidoscopeOff,
          onPressed: isExporting ? null : actions.toggleKaleidoscope,
          selected: kaleidoscopeEnabled,
          onLongPress:
              isExporting ? null : () => _showKaleidoscopeModal(context),
          isCompact: true,
          delay: const Duration(milliseconds: 140),
          sortOrder: 5,
        ),
      if (supportsAuxiliaryTools)
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
          delay: const Duration(milliseconds: 160),
          sortOrder: 6,
        ),
      if (supportsAuxiliaryTools)
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
      if (supportsAuxiliaryTools)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerFractalMusicFab'),
          icon: Icons.music_note,
          tooltip: fractalMusicEnabled
              ? l10n.tooltipFractalMusicOn
              : l10n.tooltipFractalMusicOff,
          onPressed: isExporting ? null : actions.toggleFractalMusic,
          selected: fractalMusicEnabled,
          isCompact: true,
          delay: const Duration(milliseconds: 200),
          sortOrder: 8,
        ),
      _ViewerOverflowMenu(
        isExporting: isExporting,
        l10n: l10n,
        supportsWallpaper: supportsWallpaper,
        actions: actions,
        sortOrder: 9,
      ),
      FloatingActionButtonWidget(
        key: const ValueKey('viewerFullscreenButton'),
        icon: Icons.fullscreen_rounded,
        tooltip: l10n.tooltipFullscreen,
        onPressed: isExporting ? null : actions.toggleFullscreen,
        isCompact: true,
        delay: const Duration(milliseconds: 240),
        sortOrder: 10,
      ),
      if (showFractalReport)
        FloatingActionButtonWidget(
          key: const ValueKey('viewerReportFractalFab'),
          icon: Icons.report_problem_rounded,
          tooltip: l10n.tooltipReportFractal,
          onPressed: isExporting ? null : actions.reportFractal,
          isCompact: true,
          delay: const Duration(milliseconds: 260),
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
          child: SingleChildScrollView(
            scrollDirection: isLandscape ? Axis.vertical : Axis.horizontal,
            child: ConstrainedBox(
              key: const ValueKey('viewerFabColumn'),
              constraints: BoxConstraints(
                // Landscape wraps to the available width and scrolls through
                // as many rows as needed, including enlarged touch targets.
                maxHeight: isLandscape ? double.infinity : maxFabColumnHeight,
                maxWidth: maxFabRowWidth,
              ),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Wrap(
                  direction: isLandscape ? Axis.horizontal : Axis.vertical,
                  alignment: WrapAlignment.end,
                  runAlignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final button in actionButtons)
                      if (button is AutoExploreButton ||
                          button.key ==
                              const ValueKey('viewerKaleidoscopeFab') ||
                          button is _ViewerOverflowMenu)
                        Padding(
                          padding: isLandscape
                              ? const EdgeInsets.only(left: AppSpacing.xs)
                              : const EdgeInsets.only(top: AppSpacing.xs),
                          child: button,
                        )
                      else
                        button,
                  ],
                ),
              ),
            ),
          ),
        ),
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

class _ViewerOverflowMenu extends StatelessWidget {
  final bool isExporting;
  final AppLocalizations l10n;
  final bool supportsWallpaper;
  final FractalViewControlActions actions;
  final double sortOrder;

  const _ViewerOverflowMenu({
    required this.isExporting,
    required this.l10n,
    required this.supportsWallpaper,
    required this.actions,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(sortOrder),
      child: SizedBox(
        key: const ValueKey('viewerExportButton'),
        child: Opacity(
          opacity: isExporting ? 0.38 : 1,
          child: MergeSemantics(
            child: Semantics(
              label: l10n.viewerActionsMenu,
              button: true,
              enabled: !isExporting,
              sortKey: OrdinalSortKey(sortOrder),
              child: PopupMenuButton<String>(
                key: const ValueKey('viewerOverflowMenu'),
                tooltip: l10n.viewerActionsMenu,
                enabled: !isExporting,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  fixedSize: Size.square(AccessibleSizing.touchTargetSize(
                    largeTargets: context
                            .watch<AccessibilityService?>()
                            ?.largeTargetsEnabled ??
                        false,
                  )),
                ).copyWith(
                  side: WidgetStateProperty.resolveWith((states) => BorderSide(
                        color: states.contains(WidgetState.focused)
                            ? HighContrastColors.focusIndicator
                            : Colors.transparent,
                        width: AccessibleSizing.focusIndicatorWidth,
                      )),
                ),
                icon: const CircularToolSurface(icon: Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case 'export':
                      actions.openExport();
                    case 'link':
                      actions.shareLink();
                    case 'image':
                      actions.shareImage();
                    case 'wallpaper':
                      actions.openWallpaper();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Text(l10n.tooltipExport),
                  ),
                  PopupMenuItem(
                    value: 'link',
                    child: Text(l10n.shareLinkAction),
                  ),
                  PopupMenuItem(
                    value: 'image',
                    child: Text(l10n.tooltipShareImage),
                  ),
                  if (supportsWallpaper)
                    PopupMenuItem(
                      value: 'wallpaper',
                      child: Text(l10n.wallpaperTitle),
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
