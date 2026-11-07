import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_control_status.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// One viewer tool identity. Placement lives in [ViewerToolLayout]; behaviour
/// comes from [ViewerCommands]; presentation is resolved by [resolveViewerTool].
///
/// A tool is declared once here and rendered by both the rail and the More
/// sheet, so the same action cannot drift between surfaces.
enum ViewerTool {
  previous,
  play,
  controls,
  palette,
  randomFractal,
  saveShare,
  randomOptions,
  randomParams,
  autoExplore,
  colorCycle,
  kaleidoscope,
  fourier,
  textOverlay,
  fullscreen,
  report,
  export,
  shareLink,
  shareImage,
  wallpaper,
}

/// Where a tool appears.
enum ViewerToolSurface { rail, saveShare, more }

/// More-sheet sections, in reading order.
enum ViewerToolSection { exploreAnimate, visualEffects, viewReport }

/// Placement: the single declaration of which tool appears where, in what order.
abstract final class ViewerToolLayout {
  static const rail = <ViewerTool>[
    ViewerTool.previous,
    ViewerTool.play,
    ViewerTool.controls,
    ViewerTool.palette,
    ViewerTool.randomFractal,
    ViewerTool.saveShare,
  ];

  static const saveShare = <ViewerTool>[
    ViewerTool.export,
    ViewerTool.shareLink,
    ViewerTool.shareImage,
    ViewerTool.wallpaper,
  ];

  static const moreSections = <ViewerToolSection, List<ViewerTool>>{
    ViewerToolSection.exploreAnimate: [
      ViewerTool.randomOptions,
      ViewerTool.randomParams,
      ViewerTool.autoExplore,
    ],
    ViewerToolSection.visualEffects: [
      ViewerTool.colorCycle,
      ViewerTool.kaleidoscope,
      ViewerTool.fourier,
      ViewerTool.textOverlay,
    ],
    ViewerToolSection.viewReport: [
      ViewerTool.fullscreen,
      ViewerTool.report,
    ],
  };

  /// Stable widget keys. Tests and semantics bind to these, not to placement.
  static String keyOf(ViewerTool tool) => switch (tool) {
        ViewerTool.previous => 'viewerPreviousFractalButton',
        ViewerTool.play => 'viewerPlayButton',
        ViewerTool.controls => 'viewerControlsButton',
        ViewerTool.palette => 'viewerPaletteButton',
        ViewerTool.randomFractal => 'viewerRandomFractalFab',
        ViewerTool.saveShare => 'viewerSaveShareButton',
        ViewerTool.randomOptions => 'viewerRandomOptionsAction',
        ViewerTool.randomParams => 'viewerRandomParamsButton',
        ViewerTool.autoExplore => 'viewerAutoExploreButton',
        ViewerTool.colorCycle => 'viewerColorCycleButton',
        ViewerTool.kaleidoscope => 'viewerKaleidoscopeFab',
        ViewerTool.fourier => 'viewerFourierFab',
        ViewerTool.textOverlay => 'viewerTextOverlayFab',
        ViewerTool.fullscreen => 'viewerFullscreenButton',
        ViewerTool.report => 'viewerReportFractalFab',
        ViewerTool.export => 'viewerOpenExportAction',
        ViewerTool.shareLink => 'viewerShareLinkAction',
        ViewerTool.shareImage => 'viewerShareImageAction',
        ViewerTool.wallpaper => 'viewerWallpaperAction',
      };
}

/// Motion commands: anything that starts, stops or configures a time-driven
/// behaviour, including the Fourier capture loop.
class ViewerMotionCommands {
  const ViewerMotionCommands({
    required this.toggleLooper,
    required this.openLooper,
    this.pauseMotion,
    this.openAutoExploreSettings,
    required this.toggleFourier,
    required this.openFourierSettings,
  });

  final VoidCallback toggleLooper;
  final VoidCallback openLooper;
  final VoidCallback? pauseMotion;
  final VoidCallback? openAutoExploreSettings;
  final VoidCallback toggleFourier;
  final VoidCallback openFourierSettings;
}

/// Presentation commands: the look and the navigation of the current view.
class ViewerPresentationCommands {
  const ViewerPresentationCommands({
    required this.openControls,
    required this.randomizeParams,
    required this.openRandomFractal,
    required this.toggleFullscreen,
    required this.cycleColorScheme,
    required this.openPalettePicker,
    required this.toggleKaleidoscope,
    required this.setKaleidoscopeSectors,
    required this.setKaleidoscopeMirror,
    required this.toggleTextOverlay,
    required this.editTextOverlay,
    this.randomizePalette,
    this.previousFractal,
    this.openRandomCategories,
  });

  final VoidCallback openControls;
  final VoidCallback randomizeParams;
  final VoidCallback openRandomFractal;
  final VoidCallback toggleFullscreen;
  final VoidCallback cycleColorScheme;
  final VoidCallback openPalettePicker;
  final VoidCallback toggleKaleidoscope;
  final ValueChanged<int> setKaleidoscopeSectors;
  final ValueChanged<bool> setKaleidoscopeMirror;
  final VoidCallback toggleTextOverlay;
  final VoidCallback editTextOverlay;
  final VoidCallback? randomizePalette;
  final VoidCallback? previousFractal;
  final VoidCallback? openRandomCategories;
}

/// Share commands: export, links, images, reports and the wallpaper sheet.
class ViewerShareCommands {
  const ViewerShareCommands({
    required this.openExport,
    required this.shareLink,
    required this.shareImage,
    required this.reportFractal,
    required this.openWallpaper,
  });

  final VoidCallback openExport;
  final VoidCallback shareLink;
  final VoidCallback shareImage;
  final VoidCallback reportFractal;
  final VoidCallback openWallpaper;
}

/// The viewer's command seam. Callers supply three groups; the HUD resolves a
/// tool to its handler in one place instead of receiving 25 flat callbacks.
class ViewerCommands {
  const ViewerCommands({
    required this.motion,
    required this.presentation,
    required this.share,
  });

  final ViewerMotionCommands motion;
  final ViewerPresentationCommands presentation;
  final ViewerShareCommands share;
}

/// Everything a tool needs to render on either surface.
class ViewerToolPresentation {
  const ViewerToolPresentation({
    required this.icon,
    required this.semanticLabel,
    this.caption,
    this.settingsLabel,
    this.settingsCaption,
    this.hint,
    this.selected,
    this.enabled = true,
    this.onPressed,
    this.onLongPress,
  });

  final IconData icon;

  /// Full action name for tooltips and semantics.
  final String semanticLabel;

  /// Short visible caption where the surface paints one.
  final String? caption;

  /// Long-press (secondary) action label for the More sheet.
  final String? settingsLabel;
  final String? settingsCaption;
  final String? hint;
  final bool? selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
}

/// Inputs that decide a tool's presentation.
class ViewerToolContext {
  const ViewerToolContext({
    required this.l10n,
    required this.commands,
    required this.onShowSaveShare,
    required this.onShowMore,
    required this.onShowRandomOptions,
    required this.onShowKaleidoscope,
    required this.wallpaperAvailable,
    required this.isExporting,
    required this.tiny,
    required this.short,
    required this.canGoPreviousFractal,
    required this.looperPlaying,
    required this.looperAvailable,
    required this.kaleidoscopeEnabled,
    required this.fourierEnabled,
    required this.textOverlayEnabled,
    required this.showFractalReport,
    required this.supportsAuxiliaryTools,
    required this.autoExplore,
    required this.autoExploreStatus,
    this.surface = ViewerToolSurface.more,
  });

  final AppLocalizations l10n;
  final ViewerCommands commands;
  final VoidCallback onShowSaveShare;
  final VoidCallback onShowMore;
  final VoidCallback onShowRandomOptions;
  final VoidCallback onShowKaleidoscope;
  final bool wallpaperAvailable;
  final bool isExporting;
  final bool tiny;
  final bool short;
  final bool canGoPreviousFractal;
  final bool looperPlaying;
  final bool looperAvailable;
  final bool kaleidoscopeEnabled;
  final bool fourierEnabled;
  final bool textOverlayEnabled;
  final bool showFractalReport;
  final bool supportsAuxiliaryTools;
  final AutoExploreHandler? autoExplore;
  final AutoExploreControlStatus? autoExploreStatus;
  final ViewerToolSurface surface;
}

/// Auto-explore start/pause/resume as the HUD sees it.
class AutoExploreHandler {
  const AutoExploreHandler({
    required this.toggle,
    required this.resume,
  });

  final VoidCallback toggle;
  final VoidCallback resume;
}

/// True when the environment may render this tool at all.
bool viewerToolVisible(ViewerTool tool, ViewerToolContext context) =>
    switch (tool) {
      ViewerTool.autoExplore =>
        context.supportsAuxiliaryTools && context.autoExplore != null,
      ViewerTool.kaleidoscope ||
      ViewerTool.fourier ||
      ViewerTool.textOverlay =>
        context.supportsAuxiliaryTools,
      ViewerTool.report => context.showFractalReport,
      ViewerTool.wallpaper => context.wallpaperAvailable,
      _ => true,
    };

/// Resolve one tool for the given surface. This is the single place that knows
/// a tool's icon, labels, state and handlers.
ViewerToolPresentation resolveViewerTool(
  ViewerTool tool,
  ViewerToolContext context,
) {
  final l10n = context.l10n;
  final commands = context.commands;
  final exporting = context.isExporting;
  final tiny = context.tiny;
  final short = context.short;
  VoidCallback? gated(VoidCallback? action) => exporting ? null : action;

  switch (tool) {
    case ViewerTool.previous:
      return ViewerToolPresentation(
        icon: Icons.arrow_back_rounded,
        semanticLabel: l10n.hudPreviousFractal,
        caption: l10n.viewerBackCompact,
        enabled: context.canGoPreviousFractal,
        onPressed: gated(commands.presentation.previousFractal),
      );
    case ViewerTool.play:
      return ViewerToolPresentation(
        icon: context.looperPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        semanticLabel: context.looperPlaying
            ? l10n.tooltipPauseLooper
            : l10n.tooltipPlayLooper,
        caption:
            context.looperPlaying ? l10n.actionPause : l10n.viewerPlayCompact,
        selected: context.looperPlaying,
        enabled: context.looperAvailable,
        onPressed: gated(commands.motion.toggleLooper),
        onLongPress: gated(commands.motion.openLooper),
      );
    case ViewerTool.controls:
      return ViewerToolPresentation(
        icon: Icons.tune_rounded,
        semanticLabel: l10n.viewerEditTools,
        caption: l10n.viewerEditCompact,
        onPressed: gated(context.onShowMore),
        onLongPress: gated(commands.presentation.openControls),
      );
    case ViewerTool.palette:
      return ViewerToolPresentation(
        icon: Icons.palette_outlined,
        semanticLabel: l10n.viewerChooseColors,
        caption: l10n.viewerColorCompact,
        onPressed: gated(commands.presentation.openPalettePicker),
        onLongPress: gated(commands.presentation.randomizePalette ??
            commands.presentation.cycleColorScheme),
      );
    case ViewerTool.randomFractal:
      return ViewerToolPresentation(
        icon: Icons.shuffle_rounded,
        semanticLabel: l10n.tooltipRandomFractal,
        caption: l10n.viewerMixCompact,
        onPressed: gated(commands.presentation.openRandomFractal),
        onLongPress: gated(commands.presentation.openRandomCategories ??
            context.onShowRandomOptions),
      );
    case ViewerTool.saveShare:
      return ViewerToolPresentation(
        icon: Icons.ios_share_rounded,
        semanticLabel: l10n.viewerActionSectionSaveShare,
        caption: l10n.viewerSaveCompact,
        onPressed: gated(context.onShowSaveShare),
      );
    case ViewerTool.randomOptions:
      return ViewerToolPresentation(
        icon: Icons.shuffle_rounded,
        semanticLabel: l10n.randomOptionsTitle,
        caption: tiny ? l10n.viewerActionSettingsRandomCompact : null,
        onPressed: gated(context.onShowRandomOptions),
      );
    case ViewerTool.randomParams:
      return ViewerToolPresentation(
        icon: Icons.tune_rounded,
        semanticLabel: l10n.tooltipRandomizeWithControls,
        caption: l10n.randomize,
        settingsLabel: l10n.viewerActionSettingsControls,
        settingsCaption: tiny ? l10n.controlsTitle : null,
        onPressed: gated(commands.presentation.randomizeParams),
        onLongPress: gated(commands.presentation.openControls),
      );
    case ViewerTool.autoExplore:
      final status = context.autoExploreStatus!;
      return ViewerToolPresentation(
        icon:
            status.isMotionActive ? Icons.pause_rounded : Icons.explore_rounded,
        semanticLabel: status.primaryActionLabel(
          startLabel: l10n.tooltipStartExplore,
          pauseLabel: l10n.tooltipPauseExplore,
          resumeLabel: l10n.actionResume,
        ),
        caption: short ? l10n.tabExplore : null,
        settingsLabel: l10n.viewerActionSettingsExplore,
        settingsCaption: tiny ? l10n.viewerActionSettingsExploreCompact : null,
        selected: status.isMotionActive,
        onPressed: gated(() {
          if (status.resumesFromTemporaryYield) {
            context.autoExplore!.resume();
          } else {
            context.autoExplore!.toggle();
          }
        }),
        onLongPress: gated(commands.motion.openAutoExploreSettings),
      );
    case ViewerTool.colorCycle:
      return ViewerToolPresentation(
        icon: Icons.palette_rounded,
        semanticLabel: l10n.viewerActionSettingsCyclePalette,
        caption: tiny ? l10n.viewerActionSettingsCyclePaletteCompact : null,
        settingsLabel: l10n.viewerActionSettingsPalette,
        settingsCaption: tiny ? l10n.viewerActionSettingsPaletteCompact : null,
        onPressed: gated(commands.presentation.cycleColorScheme),
        onLongPress: gated(commands.presentation.openPalettePicker),
      );
    case ViewerTool.kaleidoscope:
      return ViewerToolPresentation(
        icon: Icons.filter_vintage_rounded,
        semanticLabel: context.kaleidoscopeEnabled
            ? l10n.tooltipKaleidoscopeOn
            : l10n.tooltipKaleidoscopeOff,
        caption: short ? l10n.hudKaleidoscope : null,
        settingsLabel: l10n.viewerActionSettingsKaleidoscope,
        settingsCaption: tiny ? l10n.kaleidoscopeSectors : null,
        selected: context.kaleidoscopeEnabled,
        onPressed: gated(commands.presentation.toggleKaleidoscope),
        onLongPress: gated(context.onShowKaleidoscope),
      );
    case ViewerTool.fourier:
      return ViewerToolPresentation(
        icon: Icons.blur_on_rounded,
        semanticLabel: context.fourierEnabled
            ? l10n.tooltipFourierOn
            : l10n.tooltipFourierOff,
        caption: tiny
            ? l10n.viewerActionSettingsFourierCompactTitle
            : (short ? l10n.fourierSettingsTitle : null),
        settingsLabel: l10n.viewerActionSettingsFourier,
        settingsCaption: tiny ? l10n.viewerActionSettingsFourierCompact : null,
        hint:
            '${l10n.fourierOptionsDescription} ${l10n.viewerSecondaryActionHint}',
        selected: context.fourierEnabled,
        onPressed: gated(commands.motion.toggleFourier),
        onLongPress: gated(commands.motion.openFourierSettings),
      );
    case ViewerTool.textOverlay:
      return ViewerToolPresentation(
        icon: Icons.format_quote_rounded,
        semanticLabel: context.textOverlayEnabled
            ? l10n.tooltipTextOverlayOn
            : l10n.tooltipTextOverlayOff,
        caption: tiny
            ? l10n.viewerActionSettingsTextCompactTitle
            : (short ? l10n.textOverlayTitle : null),
        settingsLabel: l10n.viewerActionSettingsText,
        settingsCaption: tiny ? l10n.viewerActionSettingsTextCompact : null,
        selected: context.textOverlayEnabled,
        onPressed: gated(commands.presentation.toggleTextOverlay),
        onLongPress: gated(commands.presentation.editTextOverlay),
      );
    case ViewerTool.fullscreen:
      return ViewerToolPresentation(
        icon: Icons.fullscreen_rounded,
        semanticLabel: l10n.tooltipFullscreen,
        onPressed: gated(commands.presentation.toggleFullscreen),
      );
    case ViewerTool.report:
      return ViewerToolPresentation(
        icon: Icons.report_problem_outlined,
        semanticLabel: l10n.tooltipReportFractal,
        caption: tiny ? l10n.viewerActionSettingsReportCompact : null,
        onPressed: gated(commands.share.reportFractal),
      );
    case ViewerTool.export:
      return ViewerToolPresentation(
        icon: Icons.file_download_outlined,
        semanticLabel: l10n.tooltipExport,
        onPressed: gated(commands.share.openExport),
      );
    case ViewerTool.shareLink:
      return ViewerToolPresentation(
        icon: Icons.link_rounded,
        semanticLabel: l10n.shareLinkAction,
        caption: short ? l10n.viewerCopyLinkAction : null,
        onPressed: gated(commands.share.shareLink),
      );
    case ViewerTool.shareImage:
      return ViewerToolPresentation(
        icon: Icons.image_outlined,
        semanticLabel: l10n.tooltipShareImage,
        onPressed: gated(commands.share.shareImage),
      );
    case ViewerTool.wallpaper:
      return ViewerToolPresentation(
        icon: Icons.wallpaper_rounded,
        semanticLabel: l10n.wallpaperTitle,
        onPressed: gated(commands.share.openWallpaper),
      );
  }
}
