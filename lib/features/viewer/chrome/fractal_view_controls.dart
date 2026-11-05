import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/features/viewer/chrome/viewer_overlay_flow.dart';
import 'package:flutter_fractals/features/viewer/chrome/viewer_tools.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';

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
  final ViewerCommands commands;

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
    required this.commands,
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
                    final toolContext = _toolContext(
                      context,
                      l10n,
                      tiny: false,
                      short: false,
                    );
                    final buttons = <_ViewerTool>[
                      for (final (index, tool)
                          in ViewerToolLayout.rail.indexed)
                        if (viewerToolVisible(tool, toolContext))
                          _railTool(tool, toolContext, index),
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

  ViewerOverlayFlow _overlayFlow(BuildContext context) => ViewerOverlayFlow(
        context: context,
        pauseMotion: commands.motion.pauseMotion,
      );

  ViewerToolContext _toolContext(
    BuildContext context,
    AppLocalizations l10n, {
    required bool tiny,
    required bool short,
    AutoExploreHandler? autoExplore,
    AutoExploreControlStatus? autoExploreStatus,
    ViewerToolSurface surface = ViewerToolSurface.more,
    BuildContext? optionsContext,
  }) {
    return ViewerToolContext(
      l10n: l10n,
      commands: commands,
      onShowSaveShare: () => _showSaveShare(context),
      onShowMore: () => _showMore(context),
      onShowRandomOptions: () =>
          _showRandomOptionsModal(optionsContext ?? context),
      onShowKaleidoscope: () =>
          _showKaleidoscopeModal(optionsContext ?? context),
      wallpaperAvailable: ExportActionAvailability.canSetWallpaper(
          isWeb: kIsWeb, platform: defaultTargetPlatform),
      isExporting: isExporting,
      tiny: tiny,
      short: short,
      canGoPreviousFractal: canGoPreviousFractal,
      looperPlaying: looperPlaying,
      looperAvailable: looperAvailable,
      kaleidoscopeEnabled: kaleidoscopeEnabled,
      fourierEnabled: fourierEnabled,
      textOverlayEnabled: textOverlayEnabled,
      showFractalReport: showFractalReport,
      supportsAuxiliaryTools: supportsAuxiliaryTools,
      autoExplore: autoExplore,
      autoExploreStatus: autoExploreStatus,
      surface: surface,
    );
  }

  _ViewerTool _railTool(
      ViewerTool tool, ViewerToolContext context, int order) {
    final presentation = resolveViewerTool(tool, context);
    return _ViewerTool(
      toolKey: ValueKey(ViewerToolLayout.keyOf(tool)),
      icon: presentation.icon,
      label: presentation.caption ?? presentation.semanticLabel,
      semanticLabel: presentation.semanticLabel,
      selected: presentation.selected,
      showLabel: false,
      sortOrder: order.toDouble(),
      onPressed: presentation.enabled ? presentation.onPressed : null,
      onLongPress: presentation.enabled ? presentation.onLongPress : null,
    );
  }

  /// Save/export actions live behind one primary button instead of a section
  /// buried in the More sheet.
  void _showSaveShare(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final short = MediaQuery.of(context).textScaler.scale(14) > 14;
    _overlayFlow(context).presentCommand(
      builder: (sheetContext) {
        final toolContext = _toolContext(context, l10n,
            tiny: false, short: short, surface: ViewerToolSurface.saveShare);
        Widget resolvedRow(ViewerTool tool, int order) {
          final presentation = resolveViewerTool(tool, toolContext);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ViewerTool(
              toolKey: ValueKey(ViewerToolLayout.keyOf(tool)),
              icon: presentation.icon,
              label: presentation.caption ?? presentation.semanticLabel,
              semanticLabel: presentation.semanticLabel,
              row: true,
              dense: short,
              sortOrder: order.toDouble(),
              selected: presentation.selected,
              onPressed: isExporting || presentation.onPressed == null
                  ? null
                  : () =>
                      Navigator.of(sheetContext).pop(presentation.onPressed),
            ),
          );
        }

        final visible = [
          for (final tool in ViewerToolLayout.saveShare)
            if (viewerToolVisible(tool, toolContext)) tool,
        ];
        return AppOptionsSheet(
          icon: Icons.ios_share_rounded,
          title: l10n.viewerActionSectionSaveShare,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, tool) in visible.indexed)
                resolvedRow(tool, index),
            ],
          ),
        );
      },
    );
  }

  void _showMore(BuildContext context) {
    // Opening the menu freezes the scene so its rows act on what the user saw.
    final l10n = AppLocalizations.of(context)!;
    final contextForOptions = context;
    // The viewer-scoped service is below the Navigator, not above its route.
    final explore = context.read<AutoExploreService?>();
    _overlayFlow(context).presentCommand(
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
            final toolContext = _toolContext(
              context,
              l10n,
              tiny: tiny,
              short: short,
              autoExplore: service == null
                  ? null
                  : AutoExploreHandler(
                      toggle: service.toggle, resume: service.resume),
              autoExploreStatus: status,
              optionsContext: contextForOptions,
            );
            var rowOrder = 0.0;
            Widget section(String label) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: Semantics(
                      header: true,
                      child: Text(label,
                          style: Theme.of(context).textTheme.titleSmall)),
                );
            Widget rowFor(ViewerTool tool) {
              final presentation = resolveViewerTool(tool, toolContext);
              final order = rowOrder++;
              final secondary = presentation.onLongPress;
              VoidCallback close(VoidCallback callback) =>
                  () => Navigator.of(sheetContext).pop(callback);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ViewerTool(
                      toolKey: ValueKey(ViewerToolLayout.keyOf(tool)),
                      icon: presentation.icon,
                      label: presentation.caption ?? presentation.semanticLabel,
                      semanticLabel: presentation.semanticLabel,
                      semanticHint: presentation.hint,
                      row: true,
                      dense: short,
                      sortOrder: order,
                      selected: presentation.selected,
                      onPressed: !presentation.enabled ||
                              presentation.onPressed == null
                          ? null
                          : close(presentation.onPressed!),
                      onLongPress: !presentation.enabled || secondary == null
                          ? null
                          : close(secondary),
                    ),
                    if (secondary != null &&
                        presentation.settingsLabel != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: _ViewerTool(
                          toolKey: ValueKey(
                              '${ViewerToolLayout.keyOf(tool)}Options'),
                          sortOrder: order + 0.5,
                          icon: Icons.settings_outlined,
                          label: presentation.settingsCaption ??
                              presentation.settingsLabel!,
                          semanticLabel: presentation.settingsLabel,
                          row: true,
                          dense: short,
                          onPressed: isExporting ? null : close(secondary),
                        ),
                      ),
                  ],
                ),
              );
            }

            Widget sectionBlock(ViewerToolSection sectionId, String label) {
              final tools = [
                for (final tool in ViewerToolLayout.moreSections[sectionId]!)
                  if (viewerToolVisible(tool, toolContext)) tool,
              ];
              if (tools.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  section(label),
                  for (final tool in tools) ...[
                    if (tool == ViewerTool.autoExplore &&
                        (status?.showsYieldBadge ?? false))
                      Text(l10n.autoExplorePausedUserCorrection),
                    rowFor(tool),
                  ],
                ],
              );
            }

            final content = FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sectionBlock(ViewerToolSection.exploreAnimate,
                      l10n.viewerActionSectionExploreAnimate),
                  sectionBlock(ViewerToolSection.visualEffects,
                      l10n.viewerActionSectionVisualEffects),
                  sectionBlock(ViewerToolSection.viewReport,
                      l10n.viewerActionSectionViewReport),
                ],
              ),
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
    );
  }

  void _showRandomOptionsModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _overlayFlow(context).presentOptions<void>(
      icon: Icons.shuffle_rounded,
      title: l10n.randomOptionsTitle,
      subtitle: l10n.randomOptionsSubtitle,
      child: Builder(builder: (sheetContext) {
        Widget option(IconData icon, String label, String description,
                VoidCallback command) =>
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ViewerTool(
                toolKey: ValueKey('randomOption_$label'),
                icon: icon,
                label: label,
                description: description,
                trailingIcon: Icons.chevron_right_rounded,
                row: true,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  command();
                },
              ),
            );
        return Column(children: [
          option(Icons.shuffle_rounded, l10n.tooltipRandomFractal,
              l10n.randomOptionsCatalogDescription,
              commands.presentation.openRandomFractal),
          option(Icons.tune_rounded, l10n.randomize,
              l10n.randomOptionsParamsDescription,
              commands.presentation.randomizeParams),
        ]);
      }),
    );
  }

  void _showKaleidoscopeModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var selectedSectors = kaleidoscopeSectors;
    var mirrorEnabled = kaleidoscopeMirror;
    _overlayFlow(context).present<void>(
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
                            commands.presentation.setKaleidoscopeSectors(sectors);
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
                  commands.presentation.setKaleidoscopeMirror(value);
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

/// Keep all input, haptics and semantics on AppToolButton. The caption is a
/// paint-only layer over the same hit region, never a second tap handler.
class _ViewerTool extends StatefulWidget {
  final Key toolKey;
  final IconData icon;
  final String label;
  final String? semanticLabel;
  final String? semanticHint;
  final String? description;
  final IconData? trailingIcon;
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
      this.description,
      this.trailingIcon,
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
                  Expanded(
                    child: widget.description == null
                        ? caption
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [caption, Text(widget.description!)],
                          ),
                  ),
                  if (widget.trailingIcon != null)
                    Icon(widget.trailingIcon, size: 20),
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
