import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Where one viewer control surface is drawn, or that it is not drawn.
enum ViewerChromeSlot {
  /// The surface is not drawn.
  hidden,

  /// The surface is drawn at a fixed offset in the viewer stack.
  fixed,

  /// The surface is drawn inside the shared scroll column, below the header.
  ///
  /// Only the tools region uses this slot. When it does, it also draws the
  /// header at the top of its own column, because the header cannot stay fixed
  /// on a viewport that short.
  scrolled,
}

/// One computed layout for the viewer's control surfaces.
///
/// The viewer used to combine five flags inline across thirteen stacked
/// regions. This value type owns that arithmetic, so the short-viewport rules
/// can be asserted as data instead of by pumping a whole viewer at every size.
@immutable
final class ViewerChromeLayout {
  const ViewerChromeLayout({
    required this.header,
    required this.tools,
    required this.hudVisible,
    required this.hudHeight,
    required this.hudFullHeight,
  });

  /// Computes the layout from the viewer's current inputs.
  ///
  /// [usesCoreChrome] is the catalog-family gate. [showsCoreChrome] is the same
  /// gate with fullscreen-unobtrusive removed. [canPop] allows a back header for
  /// other families and for routes that capture instead of navigating.
  factory ViewerChromeLayout.compute({
    required double viewportHeight,
    required double topInset,
    required double bottomInset,
    required double overlayTop,
    required double normalHudHeight,
    required double minimumUsableHudHeight,
    required double compactRowHeight,
    required bool usesCoreChrome,
    required bool showsCoreChrome,
    required bool controlsVisible,
    required bool hasTools,
    required bool canPop,
    required bool captureMode,
  }) {
    final hudFullHeight = normalHudHeight < minimumUsableHudHeight;
    final hudHeight = hudFullHeight
        ? math.max(0.0, viewportHeight - topInset)
        : normalHudHeight;

    // A fixed title plus toolbar spacers can leave less than one whole touch
    // target. Let the title scroll away in that case; the normal phone keeps its
    // separate header and primary card.
    final toolsScrolled =
        viewportHeight - overlayTop - bottomInset - 24 < compactRowHeight + 16;

    // A full-height HUD owns the viewport, and a scrolled tools column draws the
    // header itself, so neither may also place a fixed header.
    final headerHidden = (controlsVisible && hudFullHeight) ||
        (toolsScrolled && showsCoreChrome && !controlsVisible);
    final headerShown = showsCoreChrome || (!captureMode && canPop);
    final toolsShown = showsCoreChrome && !controlsVisible && hasTools;

    return ViewerChromeLayout(
      header: !headerShown || headerHidden
          ? ViewerChromeSlot.hidden
          : ViewerChromeSlot.fixed,
      tools: !toolsShown
          ? ViewerChromeSlot.hidden
          : (toolsScrolled
              ? ViewerChromeSlot.scrolled
              : ViewerChromeSlot.fixed),
      hudVisible: usesCoreChrome && controlsVisible,
      hudHeight: hudHeight,
      hudFullHeight: hudFullHeight,
    );
  }

  /// Placement of the viewer header.
  final ViewerChromeSlot header;

  /// Placement of the tools region.
  final ViewerChromeSlot tools;

  /// Whether the controls HUD is drawn.
  final bool hudVisible;

  /// Height of the HUD region, before it builds itself.
  final double hudHeight;

  /// Whether the HUD takes the viewport because it cannot fit its minimum.
  final bool hudFullHeight;

  /// Whether the tools region scrolls with the header.
  bool get toolsScrolled => tools == ViewerChromeSlot.scrolled;
}
