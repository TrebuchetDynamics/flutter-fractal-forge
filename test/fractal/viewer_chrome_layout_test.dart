import 'package:flutter_fractals/features/viewer/chrome/viewer_chrome_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// The viewer draws its control surfaces from [ViewerChromeLayout]. These tests
/// pin the short-viewport rules as data, without pumping a whole viewer.
void main() {
  ViewerChromeLayout layout({
    double viewportHeight = 800,
    double topInset = 24,
    double bottomInset = 48,
    double overlayTop = 100,
    double? normalHudHeight,
    double minimumUsableHudHeight = 177,
    double compactRowHeight = 60,
    bool usesCoreChrome = true,
    bool showsCoreChrome = true,
    bool controlsVisible = false,
    bool hasTools = true,
    bool canPop = true,
    bool captureMode = false,
  }) {
    return ViewerChromeLayout.compute(
      viewportHeight: viewportHeight,
      topInset: topInset,
      bottomInset: bottomInset,
      overlayTop: overlayTop,
      normalHudHeight: normalHudHeight ?? viewportHeight * 0.55,
      minimumUsableHudHeight: minimumUsableHudHeight,
      compactRowHeight: compactRowHeight,
      usesCoreChrome: usesCoreChrome,
      showsCoreChrome: showsCoreChrome,
      controlsVisible: controlsVisible,
      hasTools: hasTools,
      canPop: canPop,
      captureMode: captureMode,
    );
  }

  group('a viewport with room for every surface', () {
    test('keeps the header and tools fixed while controls are closed', () {
      final chrome = layout();
      expect(chrome.header, ViewerChromeSlot.fixed);
      expect(chrome.tools, ViewerChromeSlot.fixed);
      expect(chrome.hudVisible, isFalse);
    });

    test('shows a normal-height HUD above the tools', () {
      final chrome = layout(controlsVisible: true);
      expect(chrome.hudVisible, isTrue);
      expect(chrome.hudFullHeight, isFalse);
      expect(chrome.hudHeight, 800 * 0.55);
      expect(chrome.header, ViewerChromeSlot.fixed);
      expect(chrome.tools, ViewerChromeSlot.hidden);
    });
  });

  group('a viewport too short for the HUD minimum', () {
    test('gives the HUD the viewport and hides the fixed header', () {
      final chrome = layout(viewportHeight: 300, controlsVisible: true);
      expect(chrome.hudFullHeight, isTrue);
      expect(chrome.hudVisible, isTrue);
      expect(chrome.hudHeight, 300 - 24);
      expect(chrome.header, ViewerChromeSlot.hidden);
      expect(chrome.tools, ViewerChromeSlot.hidden);
    });

    test('scrolls the tools with the header while controls are closed', () {
      final chrome = layout(viewportHeight: 200);
      expect(chrome.tools, ViewerChromeSlot.scrolled);
      expect(chrome.toolsScrolled, isTrue);
      expect(chrome.header, ViewerChromeSlot.hidden,
          reason: 'the scrolled tools column draws the header itself');
    });
  });

  group('gates that are not about height', () {
    test('a non-core family keeps a back header and no tools', () {
      final chrome = layout(usesCoreChrome: false, showsCoreChrome: false);
      expect(chrome.header, ViewerChromeSlot.fixed);
      expect(chrome.tools, ViewerChromeSlot.hidden);
      expect(chrome.hudVisible, isFalse);
    });

    test('a capture route without a back destination draws no header', () {
      final chrome = layout(
        usesCoreChrome: false,
        showsCoreChrome: false,
        canPop: false,
        captureMode: true,
      );
      expect(chrome.header, ViewerChromeSlot.hidden);
    });

    test('fullscreen-unobtrusive keeps the HUD gate but drops core chrome', () {
      final chrome = layout(
        showsCoreChrome: false,
        controlsVisible: true,
        canPop: false,
      );
      expect(chrome.tools, ViewerChromeSlot.hidden);
      expect(chrome.hudVisible, isTrue,
          reason: 'the HUD gate is the catalog family, not the fullscreen flag');
      expect(chrome.header, ViewerChromeSlot.hidden);
    });

    test('a viewer without tools never scrolls them', () {
      final chrome = layout(viewportHeight: 200, hasTools: false);
      expect(chrome.tools, ViewerChromeSlot.hidden);
      expect(chrome.header, ViewerChromeSlot.hidden,
          reason: 'a scrolled core viewport hides its fixed header');
    });
  });

  test('the HUD minimum is inclusive at its boundary', () {
    final atMinimum = layout(normalHudHeight: 177);
    final belowMinimum = layout(normalHudHeight: 176.9);
    expect(atMinimum.hudFullHeight, isFalse);
    expect(belowMinimum.hudFullHeight, isTrue);
  });
}
