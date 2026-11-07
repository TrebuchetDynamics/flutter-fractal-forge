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
    // A single row keeps the scene visible; enlarged labels scroll horizontally.
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  key: const ValueKey('viewerFabColumn'),
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(builder: (context, constraints) {
                    final target = AccessibleSizing.touchTargetSize(
                        largeTargets: context
                                .watch<AccessibilityService?>()
                                ?.largeTargetsEnabled ??
                            false);
                    final toolContext = _toolContext(
                      context,
                      l10n,
                      tiny: false,
                      short: false,
                    );
                    final buttons = [
                      for (final (index, tool) in ViewerToolLayout.rail.indexed)
                        if (viewerToolVisible(tool, toolContext))
                          _railTool(tool, toolContext, index, showLabel: true),
                    ];
                    // Measure whole captions, not individual words. Never wrap
                    // the toolbar or shrink a touch target to fit a phone.
                    final widths = [
                      for (final button in buttons)
                        math.min(constraints.maxWidth - 4,
                            _captionWidth(context, button.label, target)),
                    ];
                    final availableWidth = constraints.maxWidth - 4;
                    final totalWidth =
                        widths.fold(0.0, (sum, width) => sum + width);
                    final extra = math.max(0.0, availableWidth - totalWidth) /
                        buttons.length;
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        key: const ValueKey('viewerToolbarScroll'),
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          child: FocusTraversalGroup(
                            policy: OrderedTraversalPolicy(),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final (index, button) in buttons.indexed)
                                    SizedBox(
                                      key: button.toolKey ==
                                              const ValueKey(
                                                  'viewerSaveShareButton')
                                          ? const ValueKey('viewerExportButton')
                                          : null,
                                      width: widths[index] + extra,
                                      child: button,
                                    ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  double _captionWidth(BuildContext context, String caption, double target) {
    final painter = TextPainter(
      text: TextSpan(
          text: caption, style: Theme.of(context).textTheme.labelMedium),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = math.max(target, painter.width.ceilToDouble() + 8);
    painter.dispose();
    return width;
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

  _ViewerTool _railTool(ViewerTool tool, ViewerToolContext context, int order,
      {required bool showLabel}) {
    final presentation = resolveViewerTool(tool, context);
    return _ViewerTool(
      toolKey: ValueKey(ViewerToolLayout.keyOf(tool)),
      icon: presentation.icon,
      label: presentation.caption ?? presentation.semanticLabel,
      semanticLabel: presentation.semanticLabel,
      selected: presentation.selected,
      primary: tool == ViewerTool.saveShare,
      showLabel: showLabel,
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
            VoidCallback close(VoidCallback callback) =>
                () => Navigator.of(sheetContext).pop(callback);
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
                    if (secondary != null && presentation.settingsLabel != null)
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
                  _ViewerTool(
                    toolKey: const ValueKey('viewerEditParametersAction'),
                    icon: Icons.tune_rounded,
                    label: l10n.controlsTitle,
                    row: true,
                    dense: short,
                    sortOrder: -1,
                    onPressed: isExporting
                        ? null
                        : close(commands.presentation.openControls),
                  ),
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
                            icon: Icons.tune_rounded,
                            title: l10n.viewerEditTools,
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
          option(
              Icons.shuffle_rounded,
              l10n.tooltipRandomFractal,
              l10n.randomOptionsCatalogDescription,
              commands.presentation.openRandomFractal),
          option(
              Icons.tune_rounded,
              l10n.randomize,
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
                            commands.presentation
                                .setKaleidoscopeSectors(sectors);
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
  final bool primary;
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
      this.primary = false,
      this.showLabel = true,
      this.selected,
      this.sortOrder});

  @override
  State<_ViewerTool> createState() => _ViewerToolState();
}

class _ViewerToolState extends State<_ViewerTool> {
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final target = AccessibleSizing.touchTargetSize(
        largeTargets:
            context.watch<AccessibilityService?>()?.largeTargetsEnabled ??
                false);
    final disabled = widget.onPressed == null && widget.onLongPress == null;
    final foreground = widget.primary
        ? colors.onPrimary
        : !widget.row && widget.selected == true
            ? colors.onSecondaryContainer
            : colors.onSurface;
    final caption = Text(widget.label,
        textAlign: widget.row ? TextAlign.start : TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: foreground, height: widget.dense ? 1.1 : null));
    // A row keeps the full width tappable but paints the circle on the leading
    // edge; drawing the icon and the circle again in the label area duplicated
    // both and left a stray circle across the text.
    final visual = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.row && !widget.dense ? 8 : 0,
          vertical: widget.dense ? 0 : 8),
      child: !widget.showLabel
          ? Icon(widget.icon, size: 22, color: foreground)
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
                  Icon(widget.icon, size: 22, color: foreground),
                  const SizedBox(height: 4),
                  caption
                ]),
    );
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) {
          if (mounted) setState(() => _hovered = false);
        },
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) {
            if (mounted) setState(() => _pressed = false);
          },
          onPointerCancel: (_) {
            if (mounted) setState(() => _pressed = false);
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: Opacity(
                  // Dense rows keep the full-width hit area and semantics but paint
                  // no circular surface; the label alone carries the row.
                  opacity: !widget.row || widget.dense ? 0 : 1,
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
                margin: null,
                constraints:
                    BoxConstraints(minWidth: target, minHeight: target),
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
                        borderRadius: BorderRadius.circular(12),
                        color: widget.primary
                            ? colors.primary.withValues(
                                alpha: disabled
                                    ? 0.38
                                    : _pressed
                                        ? 0.8
                                        : _hovered
                                            ? 0.9
                                            : 1)
                            : widget.selected == true
                                ? colors.secondaryContainer
                                : !disabled && (_hovered || _pressed)
                                    ? colors.onSurface.withValues(
                                        alpha: _pressed ? 0.12 : 0.08)
                                    : Colors.transparent,
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
    super.surfaceAlignment,
  });
}
