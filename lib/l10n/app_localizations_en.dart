// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Fractals';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabAr => 'AR';

  @override
  String get catalogTitle => 'Fractal Catalog';

  @override
  String get catalogSearchHint => 'Search fractals';

  @override
  String get catalogSearchEmpty => 'No fractals match your search.';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get viewerTitle => 'Fractal Viewer';

  @override
  String get controlsTitle => 'Controls';

  @override
  String get presetsTitle => 'Presets';

  @override
  String get builtInPresets => 'Built-in';

  @override
  String get userPresets => 'Your Presets';

  @override
  String get loadingPresets => 'Loading presets…';

  @override
  String get noUserPresets => 'No saved presets yet.';

  @override
  String get presetsLoadFailed => 'Couldn’t load presets.';

  @override
  String get savePreset => 'Save Preset';

  @override
  String get presetNameHint => 'Preset name';

  @override
  String get presetSaved => 'Preset saved';

  @override
  String get presetNameRequired => 'Enter a preset name.';

  @override
  String presetSaveFailed(Object error) {
    return 'Couldn’t save preset: $error';
  }

  @override
  String get resetView => 'Reset View';

  @override
  String get resetParams => 'Reset Params';

  @override
  String get randomize => 'Randomize';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportQuickPresets => 'Quick Presets';

  @override
  String get exportPresetSocial => 'Social';

  @override
  String get exportPresetHighQuality => 'High Quality';

  @override
  String get exportPresetWeb => 'Web';

  @override
  String get exportPresetTransparent => 'Transparent';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportFormatHintPng =>
      'Lossless quality, supports transparency. Best for editing.';

  @override
  String get exportFormatHintJpg =>
      'Smaller file size, great for sharing. No transparency.';

  @override
  String get exportFormatHintWebp =>
      'Modern format with excellent compression. Wide support.';

  @override
  String get exportResolution => 'Resolution';

  @override
  String get exportWidth => 'Width';

  @override
  String get exportHeight => 'Height';

  @override
  String get exportQuality => 'Quality';

  @override
  String get exportAdvancedOptions => 'Advanced Options';

  @override
  String get exportTransparentBg => 'Transparent Background';

  @override
  String get exportTransparentBgHint => 'Remove the background for overlay use';

  @override
  String get exportEmbedMetadata => 'Embed Metadata';

  @override
  String get exportEmbedMetadataHint =>
      'Include fractal parameters in the image file';

  @override
  String get exportScreenResolution => 'Screen size';

  @override
  String get exportSummary => 'Export Summary';

  @override
  String get exportNow => 'Export Now';

  @override
  String get exportPng => 'PNG';

  @override
  String get exportTransparentPng => 'Transparent PNG';

  @override
  String get exportArScreenshot => 'Baked AR Screenshot';

  @override
  String get exportArVideo => 'Baked AR Video';

  @override
  String get exportArVideoStub =>
      'AR video export is scaffolded but not baked yet.';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get exportSaved => 'Export saved';

  @override
  String get exporting => 'Exporting...';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get share => 'Share';

  @override
  String get loadingShaders => 'Loading shaders...';

  @override
  String get moduleMandelbrot => 'Mandelbrot';

  @override
  String get moduleJulia => 'Julia';

  @override
  String get moduleBurningShip => 'Burning Ship';

  @override
  String get modulePhoenix => 'Phoenix';

  @override
  String get moduleMandelbulb => 'Mandelbulb';

  @override
  String get dimension2d => '2D';

  @override
  String get dimension3d => '3D';

  @override
  String get paramIterations => 'Iterations';

  @override
  String get paramSteps => 'Steps';

  @override
  String get paramBailout => 'Bailout';

  @override
  String get paramPower => 'Power';

  @override
  String get paramColorScheme => 'Color Scheme';

  @override
  String get paramFractalType => 'Fractal Type';

  @override
  String get paramJuliaCReal => 'Julia C (Real)';

  @override
  String get paramJuliaCImag => 'Julia C (Imag)';

  @override
  String get paramPhoenixCReal => 'Phoenix C (Real)';

  @override
  String get paramPhoenixCImag => 'Phoenix C (Imag)';

  @override
  String get paramPhoenixP => 'Phoenix P (Memory)';

  @override
  String get paramOpacity => 'Opacity';

  @override
  String get paramLockOverlay => 'Lock Overlay';

  @override
  String get paramTransparentBg => 'Transparent Background';

  @override
  String get arQualityPreset => 'AR Quality';

  @override
  String get arQualityLow => 'Low';

  @override
  String get arQualityMedium => 'Medium';

  @override
  String get arQualityHigh => 'High';

  @override
  String get arTitle => 'AR Overlay';

  @override
  String get arSelectFractal => 'Fractal';

  @override
  String get fractalSection2d => '2D';

  @override
  String get fractalSection3d => '3D';

  @override
  String get arPermissionRequest =>
      'Camera permission is required for AR mode.';

  @override
  String get arPermissionDenied => 'Camera permission denied.';

  @override
  String get arCameraUnavailable => 'No camera available.';

  @override
  String get arCameraUnavailableHelp =>
      'Make sure another app isn’t using the camera, then try again.';

  @override
  String get arOverlayOnlyExport => 'Overlay-only PNG';

  @override
  String get arBakedScreenshotExport => 'Baked camera + overlay';

  @override
  String get arVideoExport => 'Record AR Video';

  @override
  String get arVideoExportFailed => 'AR video export failed.';

  @override
  String get arVideoFallbackNotice =>
      'FFmpeg unavailable or failed. Exported a low-FPS GIF fallback (larger file, no audio).';

  @override
  String get arDuration5 => '5s';

  @override
  String get arDuration10 => '10s';

  @override
  String get arDuration15 => '15s';

  @override
  String get colorFire => 'Fire';

  @override
  String get colorOcean => 'Ocean';

  @override
  String get colorPsychedelic => 'Psychedelic';

  @override
  String get colorGrayscale => 'Grayscale';

  @override
  String get colorPhoenix => 'Phoenix';

  @override
  String get fractalTypeMandelbulb => 'Mandelbulb';

  @override
  String get fractalTypeMandelbox => 'Mandelbox';

  @override
  String get fractalTypeJulia => 'Julia';

  @override
  String get fractalTypeSierpinski => 'Sierpinski';

  @override
  String get tooltipOpenControls => 'Controls';

  @override
  String get tooltipOpenPresets => 'Presets';

  @override
  String get tooltipExport => 'Export';

  @override
  String get presetDefault => 'Default';

  @override
  String get presetClassic => 'Classic';

  @override
  String get presetSoftGlow => 'Soft Glow';

  @override
  String get presetPsychedelic => 'Psychedelic';

  @override
  String get presetDeepBloom => 'Deep Bloom';

  @override
  String get arStyleNeon => 'Neon';

  @override
  String get arStyleSoft => 'Soft';

  @override
  String get arStyleMono => 'Mono';

  @override
  String get arStyleTitle => 'Style';

  @override
  String get arShowGrid => 'Grid';

  @override
  String get arShowOutline => 'Outline';

  @override
  String get tooltipExpand => 'Expand';

  @override
  String get tooltipCollapse => 'Collapse';

  @override
  String get errorOverlayNotReady => 'Overlay not ready';

  @override
  String get errorCameraNotReady => 'Camera not ready';

  @override
  String get shaderLoadFailed => 'Failed to load shader';

  @override
  String get contextMenuResetView => 'Reset View';

  @override
  String get contextMenuOpenControls => 'Open Controls';

  @override
  String get contextMenuOpenPresets => 'Open Presets';

  @override
  String get contextMenuRandomize => 'Randomize';

  @override
  String get contextMenuExport => 'Export';

  @override
  String get gestureDoubleTapReset => 'View reset';

  @override
  String get accessibilityTitle => 'Accessibility';

  @override
  String get accessibilityHighContrast => 'High Contrast';

  @override
  String get accessibilityHighContrastHint =>
      'Use bright colors with maximum contrast';

  @override
  String get accessibilityReducedMotion => 'Reduced Motion';

  @override
  String get accessibilityReducedMotionHint =>
      'Minimize animations and transitions';

  @override
  String get accessibilityLargeTargets => 'Large Touch Targets';

  @override
  String get accessibilityLargeTargetsHint =>
      'Increase size of interactive elements';

  @override
  String get accessibilityScreenReaderActive => 'Screen reader is active';

  @override
  String get semanticFractalViewer =>
      'Interactive fractal viewer. Pinch to zoom, drag to pan.';

  @override
  String semanticFractalCard(Object name, Object dimension) {
    return '$name fractal, $dimension. Double tap to open.';
  }

  @override
  String semanticSlider(Object label, Object value, Object min, Object max) {
    return '$label slider. Current value: $value. Minimum: $min, Maximum: $max';
  }

  @override
  String get semanticNavExplore => 'Explore tab. Browse fractal catalog.';

  @override
  String get semanticNavAr => 'AR tab. View fractals in augmented reality.';

  @override
  String get semanticBackButton => 'Go back to previous screen';

  @override
  String get semanticCloseButton => 'Close this dialog';

  @override
  String get semanticSearchField => 'Search fractals by name';

  @override
  String get semanticExportButton => 'Export current fractal as image';

  @override
  String get semanticControlsButton => 'Open fractal parameter controls';

  @override
  String get semanticPresetsButton => 'Open saved presets';

  @override
  String get semanticRandomizeButton => 'Randomize all fractal parameters';

  @override
  String get semanticResetViewButton => 'Reset view to default position';

  @override
  String get semanticResetParamsButton => 'Reset all parameters to defaults';

  @override
  String semanticZoomLevel(Object percent) {
    return 'Zoom level: $percent percent';
  }

  @override
  String get semanticLoadingShaders => 'Loading fractal shaders, please wait';

  @override
  String semanticExportProgress(Object percent) {
    return 'Exporting image, $percent percent complete';
  }

  @override
  String semanticPresetItem(Object name) {
    return '$name preset. Double tap to apply.';
  }

  @override
  String semanticToggleOn(Object label) {
    return '$label, currently on. Double tap to turn off.';
  }

  @override
  String semanticToggleOff(Object label) {
    return '$label, currently off. Double tap to turn on.';
  }

  @override
  String announceFractalLoaded(Object name) {
    return '$name fractal loaded';
  }

  @override
  String announcePresetApplied(Object name) {
    return 'Preset $name applied';
  }

  @override
  String get announceExportComplete => 'Export complete';

  @override
  String get announceViewReset => 'View reset to default';

  @override
  String get announceParamsRandomized => 'Parameters randomized';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Flutter Fractals';

  @override
  String get onboardingWelcomeDescription =>
      'Explore the infinite beauty of mathematical fractals with real-time GPU-accelerated rendering.';

  @override
  String get onboardingFractalTypesTitle => 'Discover Fractal Types';

  @override
  String get onboardingFractalTypesDescription =>
      'From classic 2D fractals to stunning 3D Mandelbulb, explore a variety of mathematical art.';

  @override
  String get onboardingGesturesTitle => 'Intuitive Controls';

  @override
  String get onboardingGesturesDescription =>
      'Navigate fractals with simple, natural gestures.';

  @override
  String get onboardingGesturePan => 'Pan';

  @override
  String get onboardingGesturePanDesc => 'Drag with one finger to move around';

  @override
  String get onboardingGestureZoom => 'Zoom';

  @override
  String get onboardingGestureZoomDesc => 'Pinch to zoom in and out';

  @override
  String get onboardingGestureRotate => 'Rotate';

  @override
  String get onboardingGestureRotateDesc => 'Two-finger rotate for 3D fractals';

  @override
  String get onboardingGestureDoubleTap => 'Double Tap';

  @override
  String get onboardingGestureDoubleTapDesc => 'Quick reset to default view';

  @override
  String get onboardingFeaturesTitle => 'Powerful Features';

  @override
  String get onboardingFeaturesDescription =>
      'Create, customize, and share your fractal creations.';

  @override
  String get onboardingFeaturePresets => 'Presets';

  @override
  String get onboardingFeaturePresetsDesc =>
      'Save and load your favorite configurations';

  @override
  String get onboardingFeatureExport => 'Export';

  @override
  String get onboardingFeatureExportDesc =>
      'Save high-quality images in multiple formats';

  @override
  String get onboardingFeatureAr => 'AR Mode';

  @override
  String get onboardingFeatureArDesc => 'Overlay fractals on your camera view';

  @override
  String get shareTitle => 'Share Fractal';

  @override
  String shareSubtitle(Object fractalName) {
    return 'Check out this $fractalName fractal I created!';
  }

  @override
  String get tooltipShare => 'Share';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String shareMessage(Object fractalName, Object link) {
    return 'Check out this $fractalName fractal! $link';
  }

  @override
  String shareSubject(Object fractalName) {
    return '$fractalName Fractal - Flutter Fractals';
  }

  // History feature strings

  @override
  String get historyTitle => 'Exploration History';

  @override
  String historyPosition(int current, int total) {
    return 'Position $current of $total';
  }

  @override
  String get historyGoBack => 'Go back';

  @override
  String get historyGoForward => 'Go forward';

  @override
  String get historyTabHistory => 'History';

  @override
  String get historyTabFavorites => 'Favorites';

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptySubtitle =>
      'Start exploring fractals to build your history';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Save interesting locations to revisit later';

  @override
  String get saveFavoriteTitle => 'Save as Favorite';

  @override
  String get favoritePlaceholder => 'Enter a name for this spot';

  @override
  String get renameFavoriteTitle => 'Rename Favorite';

  @override
  String get deleteFavoriteTitle => 'Delete Favorite';

  @override
  String deleteFavoriteMessage(String name) {
    return 'Delete "$name" from favorites?';
  }

  @override
  String get saveAsFavorite => 'Save as favorite';

  @override
  String get alreadyFavorite => 'Already saved';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get tooltipOpenHistory => 'History';
}
