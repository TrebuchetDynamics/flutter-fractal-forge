// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fractal Forge';

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
  String get batchExportTitle => 'Batch Export';

  @override
  String get batchExportAllPresets => 'Export all presets';

  @override
  String get batchExportPreparing => 'Preparing…';

  @override
  String get batchExportCancelling => 'Cancelling…';

  @override
  String get batchExportCancelled => 'Cancelled';

  @override
  String get batchExportDone => 'Done';

  @override
  String get batchExportNoPresets => 'No presets to export.';

  @override
  String get batchExportSavedTo => 'Saved to:';

  @override
  String get batchExportContactSheet => 'Contact sheet';

  @override
  String get batchExportCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

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
  String get sectionActions => 'Actions';

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
  String get arSafetyWarningTitle => 'AR Safety Warning';

  @override
  String get arSafetyWarningBody =>
      '• Parental supervision is recommended when children use AR.\n• Be aware of your surroundings and keep a safe distance from objects.\n• No headset or wearable device is required.';

  @override
  String get arSafetyContinue => 'Continue';

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
  String get tooltipWallpaper => 'Set as Wallpaper';

  @override
  String get wallpaperTitle => 'Wallpaper';

  @override
  String get wallpaperAndroidNote =>
      'Exports at your device’s native resolution and sets it as wallpaper.';

  @override
  String get wallpaperIosNote =>
      'iOS doesn’t allow apps to set wallpapers directly. We’ll save the image to Photos so you can set it from there.';

  @override
  String get wallpaperTarget => 'Target';

  @override
  String get wallpaperTargetHome => 'Home';

  @override
  String get wallpaperTargetLock => 'Lock';

  @override
  String get wallpaperTargetBoth => 'Both';

  @override
  String get wallpaperPresets => 'Presets';

  @override
  String get wallpaperPresetPlain => 'Plain';

  @override
  String get wallpaperPresetHome => 'Home optimized';

  @override
  String get wallpaperPresetLock => 'Lock optimized';

  @override
  String get wallpaperSaveCopy => 'Save a copy';

  @override
  String get wallpaperSaveCopySubtitle =>
      'Also export and open the share sheet.';

  @override
  String get wallpaperApply => 'Apply';

  @override
  String get wallpaperApplied => 'Wallpaper ready';

  @override
  String get wallpaperFailed => 'Couldn’t apply wallpaper';

  @override
  String wallpaperFailedWithError(Object error) {
    return 'Couldn’t apply wallpaper: $error';
  }

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
  String get arCenter => 'Center';

  @override
  String get arMoreOptions => 'More';

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
  String get soundEffectsTitle => 'Sound Effects';

  @override
  String get soundEffectsEnabled => 'UI Sounds';

  @override
  String get soundEffectsEnabledHint =>
      'Play subtle sounds for button taps and transitions';

  @override
  String get soundEffectsVolume => 'Volume';

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
  String get semanticSplashScreen => 'Fractal Forge splash screen';

  @override
  String get splashTagline => 'Explore infinite mathematical patterns';

  @override
  String semanticOnboardingProgress(Object step, Object total) {
    return 'Onboarding progress, step $step of $total';
  }

  @override
  String get semanticSkipOnboarding => 'Skip onboarding';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Fractal Forge';

  @override
  String get onboardingWelcomeDescription =>
      'Explore infinite mathematical beauty through 350+ interactive fractals with GPU-accelerated rendering — from Mandelbrot sets to strange attractors.';

  @override
  String get onboardingWelcomeHighlight1 =>
      'Pan and pinch to navigate with deep zoom and infinite precision';

  @override
  String get onboardingWelcomeHighlight2 =>
      'Discover structure in Mandelbrot, Julia, Newton and 350+ fractal types';

  @override
  String get onboardingWelcomeHighlight3 =>
      'GPU-accelerated rendering for smooth, real-time exploration';

  @override
  String get onboardingCreateTitle => 'Create, Export & Experience in AR';

  @override
  String get onboardingCreateDescription =>
      'Adjust parameters in real time, place fractals on real surfaces with AR, and export stunning high-resolution images to share.';

  @override
  String get onboardingCreateHighlight1 =>
      'Real-time parameter controls with 60+ colour schemes';

  @override
  String get onboardingCreateHighlight2 =>
      'Augmented Reality — anchor fractals on real-world surfaces';

  @override
  String get onboardingCreateHighlight3 =>
      'Export to PNG and share — perfect for art, presentations and study';

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
  String get tooltipExitFullscreen => 'Exit fullscreen view';

  @override
  String get announceEnteredFullscreen => 'Entered fullscreen view';

  @override
  String get announceExitedFullscreen => 'Exited fullscreen view';

  @override
  String get announceMinimapShown => 'Minimap shown';

  @override
  String get announceMinimapHidden => 'Minimap hidden';

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

  @override
  String get videoExportTitle => 'Export Video';

  @override
  String get videoPresetQuickGif => 'Quick GIF';

  @override
  String get videoPresetSocial => 'Social';

  @override
  String get videoPresetHighQuality => 'High Quality';

  @override
  String get videoPresetLoop => 'Loop GIF';

  @override
  String get videoTabAnimation => 'Animation';

  @override
  String get videoTabQuality => 'Quality';

  @override
  String get videoTabAdvanced => 'Advanced';

  @override
  String get videoAnimationType => 'Animation Type';

  @override
  String get videoDuration => 'Duration';

  @override
  String get videoFrames => 'frames';

  @override
  String get videoZoomFactor => 'Zoom Factor';

  @override
  String get videoEasing => 'Easing';

  @override
  String get videoParameterSweep => 'Parameter Sweep';

  @override
  String get videoSelectParameter => 'Select Parameter';

  @override
  String get videoSweepStart => 'Start Value';

  @override
  String get videoSweepEnd => 'End Value';

  @override
  String get videoPingPong => 'Ping-Pong';

  @override
  String get videoPingPongHint => 'Animate back to start value';

  @override
  String get videoFormat => 'Format';

  @override
  String get videoResolution => 'Resolution';

  @override
  String get videoFrameRate => 'Frame Rate';

  @override
  String get videoQualityPreset => 'Quality';

  @override
  String get videoLoop => 'Loop';

  @override
  String get videoLoopHint => 'Repeat animation continuously';

  @override
  String get videoWatermark => 'Add Watermark';

  @override
  String get videoWatermarkHint => 'Add \'Flutter Fractals\' branding';

  @override
  String get videoEstimatedOutput => 'Estimated Output';

  @override
  String get videoTotalFrames => 'Total Frames';

  @override
  String get videoEstimatedSize => 'Est. File Size';

  @override
  String get videoExportNow => 'Export Video';

  @override
  String get videoExporting => 'Exporting video...';

  @override
  String videoExportProgress(Object current, Object total) {
    return 'Rendering frame $current of $total';
  }

  @override
  String get videoExportComplete => 'Video exported successfully';

  @override
  String videoExportFailed(Object error) {
    return 'Video export failed: $error';
  }

  @override
  String get tooltipExportVideo => 'Export Video';

  @override
  String get tooltipOpenHistory => 'History';

  @override
  String get autoExploreTitle => 'Auto-Explore';

  @override
  String get autoExploreSubtitle => 'Automatically discover interesting areas';

  @override
  String get tooltipStartExplore => 'Start auto-explore';

  @override
  String get tooltipPauseExplore => 'Pause auto-explore';

  @override
  String get statusIdle => 'Ready to explore';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusExploring => 'Exploring...';

  @override
  String get speedLabel => 'Speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedFast => 'Fast';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionStop => 'Stop';

  @override
  String get historyTitle => 'History';

  @override
  String historyPosition(Object current, Object total) {
    return '$current of $total';
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
      'Save your favorite views to access them quickly';

  @override
  String get saveFavoriteTitle => 'Save Favorite';

  @override
  String get favoritePlaceholder => 'Enter a name for this view';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSave => 'Save';

  @override
  String get renameFavoriteTitle => 'Rename Favorite';

  @override
  String get deleteFavoriteTitle => 'Delete Favorite';

  @override
  String deleteFavoriteMessage(Object name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get buttonDelete => 'Delete';

  @override
  String get alreadyFavorite => 'Already saved';

  @override
  String get saveAsFavorite => 'Save as favorite';

  @override
  String get disable3dMessage =>
      '3D fractals are disabled on this device.\n(Mandelbulb shader load stalls.)';

  @override
  String get deepZoomCpuFallback => 'Deep Zoom — tap for CPU precision';

  @override
  String get rendererAuto => 'Renderer preference: Auto';

  @override
  String get rendererCpu => 'Renderer preference: CPU only';

  @override
  String get rendererGpu => 'Renderer preference: GPU only (debug)';

  @override
  String get tooltipGpuDebug => 'GPU debug report';

  @override
  String get tooltipRandomFractal => 'Random Fractal';

  @override
  String get deletePresetTitle => 'Delete Preset';

  @override
  String deletePresetMessage(Object name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get presetDeleted => 'Preset deleted';

  @override
  String get presetDeleteFailed => 'Couldn\'t delete preset';

  @override
  String get renamePresetTitle => 'Rename Preset';

  @override
  String get renamePresetHint => 'New preset name';

  @override
  String get presetRenamed => 'Preset renamed';

  @override
  String get presetRenameFailed => 'Couldn\'t rename preset';

  @override
  String get tooltipDeletePreset => 'Delete preset';

  @override
  String get tooltipRenamePreset => 'Rename preset';

  @override
  String get quickActionSaveLocation => 'Save location';

  @override
  String get quickActionOpenPresets => 'Open presets';

  @override
  String get quickActionRandomFractal => 'Random fractal';

  @override
  String get quickActionBackInHistory => 'Back in view history';

  @override
  String get quickActionForwardInHistory => 'Forward in view history';

  @override
  String get quickActionRendererMode => 'Renderer mode';

  @override
  String get quickActionViewLogs => 'View logs';

  @override
  String get quickActionGpuDebugReport => 'GPU debug report';

  @override
  String get debugReportOpenShaderLab => 'Open Shader Lab';

  @override
  String get debugReportCopyJson => 'Copy JSON';

  @override
  String get rendererBackendTitle => 'Renderer Backend';

  @override
  String get rendererBackendSubtitle =>
      'Choose how fractals are rendered. Auto is recommended.';

  @override
  String get rendererBackendAuto => 'Auto';

  @override
  String get rendererBackendAutoSubtitle =>
      'Use GPU when healthy; fall back to CPU when needed.';

  @override
  String get rendererBackendCpuOnly => 'CPU only (stable)';

  @override
  String get rendererBackendCpuOnlySubtitle =>
      'Always use the stable CPU renderer.';

  @override
  String get rendererBackendGpuOnly => 'GPU only (debug)';

  @override
  String get rendererBackendGpuOnlySubtitle =>
      'Always try GPU rendering. May show black/invalid output on some devices.';

  @override
  String get cpuFallbackTryGpu => 'Try GPU';

  @override
  String get cpuFallbackReport => 'Report';

  @override
  String get shaderErrorTryAgain => 'Try Again';

  @override
  String get shaderErrorGoBack => 'Go Back';

  @override
  String logViewerTitle(Object filtered, Object total) {
    return 'Log ($filtered/$total)';
  }

  @override
  String logExportTitle(Object count) {
    return 'Export Log ($count entries)';
  }

  @override
  String get logCopyText => 'Copy Text';

  @override
  String get logShareText => 'Share Text';

  @override
  String get logShareJson => 'Share JSON';

  @override
  String get logCopied => 'Log copied to clipboard';

  @override
  String logShareFailed(Object error) {
    return 'Share failed: $error';
  }

  @override
  String get logFilterTooltip => 'Filter level';

  @override
  String get logFilterAll => 'All';

  @override
  String get logFilterDebug => 'Debug+';

  @override
  String get logFilterInfo => 'Info+';

  @override
  String get logFilterWarn => 'Warn+';

  @override
  String get logFilterError => 'Error';

  @override
  String get logNoEntries => 'No log entries';

  @override
  String get logTooltipExport => 'Export';

  @override
  String get logTooltipClear => 'Clear';

  @override
  String get exportSimpleModeHint =>
      'Simple mode — choose a quick preset, then tap Export or Share.';

  @override
  String get exportCustomizeModeHint =>
      'Customization enabled — full export controls visible.';

  @override
  String get exportButtonSimple => 'Simple';

  @override
  String get exportButtonCustomize => 'Customize';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportFormatJpg => 'JPG';

  @override
  String get exportFormatWebp => 'WebP';

  @override
  String homeUnknownFractalType(Object type) {
    return 'Unknown fractal type: $type';
  }

  @override
  String get homeFractalCountBadge => '350+ fractals';

  @override
  String get arSafetyBannerLabel =>
      'Safety warning: Parental supervision recommended. Be aware of your surroundings.';

  @override
  String get arSafetyBannerText =>
      'AR Safety: Parental supervision recommended. Be aware of your surroundings.';

  @override
  String get arStatusScanning => 'Scanning for surfaces...';

  @override
  String get arStatusSurfaceDetected =>
      'Surface detected · Tap on a highlighted area to place';

  @override
  String arStatusFractalsPlaced(Object count) {
    return '$count fractal placed · Tap to add more';
  }

  @override
  String arStatusFractalsPlacedPlural(Object count) {
    return '$count fractals placed · Tap to add more';
  }

  @override
  String get arScanTipsTitle => 'Having trouble detecting a surface?';

  @override
  String get arScanTip1 => 'Point at a textured surface (table, floor, carpet)';

  @override
  String get arScanTip2 => 'Move the camera slowly — avoid fast sweeping';

  @override
  String get arScanTip3 => 'Ensure good lighting (avoid very dark rooms)';

  @override
  String get arScanTip4 =>
      'Plain white walls and glass surfaces are hard to detect';

  @override
  String get arTooltipMoreOptions => 'More options';

  @override
  String get arTooltipShare => 'Share';

  @override
  String get arTooltipSave => 'Save';

  @override
  String get arTooltipClearAll => 'Clear all';

  @override
  String get arTooltipRescan => 'Re-scan';

  @override
  String get arScanHint =>
      'Move the camera slowly over a flat surface to detect it';

  @override
  String arPlacementSize(Object size) {
    return 'Size: ${size}m';
  }

  @override
  String get arActionShare => 'Share';

  @override
  String get arActionSave => 'Save';

  @override
  String get arActionClear => 'Clear';

  @override
  String get arActionRescan => 'Re-scan';

  @override
  String get arRemoveFractalPrompt => 'Remove this fractal?';

  @override
  String get arConfirmYes => 'Yes';

  @override
  String get arConfirmNo => 'No';

  @override
  String arErrorRemoveNode(Object error) {
    return 'Failed to remove node: $error';
  }

  @override
  String arErrorArCore(Object error) {
    return 'ARCore error: $error';
  }

  @override
  String get arNoSurfaceHit =>
      'No surface hit — tap directly on a highlighted (blue) area';

  @override
  String arErrorPlaceFractal(Object error) {
    return 'Failed to place fractal: $error';
  }

  @override
  String get arShareText => 'Fractal anchored in AR via Fractal Forge';

  @override
  String arErrorShareFailed(Object error) {
    return 'Share failed: $error';
  }

  @override
  String arSavedTo(Object path) {
    return 'Saved to $path';
  }

  @override
  String arErrorSaveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get arFractalAnchored => 'Fractal anchored to tapped surface';

  @override
  String arAnchoredStatus(Object camera) {
    return 'Anchored · $camera camera';
  }

  @override
  String get arTapToAnchor => 'Tap on surface to anchor fractal';

  @override
  String get arTooltipSwitchCamera => 'Switch camera';

  @override
  String get arErrorSurfaceDetectionUnavailable =>
      'AR surface detection is not available on this device';

  @override
  String get arErrorArCoreUnavailable =>
      'ARCore services are unavailable on this device';

  @override
  String arErrorCaptureFailed(Object error) {
    return 'Could not capture fractal: $error';
  }

  @override
  String get arTapAnywhereToPlace => 'Tap anywhere to place';

  @override
  String get arTooltipReAnchor => 'Re-anchor';

  @override
  String get arTooltipAnchorToSurface => 'Anchor to surface';

  @override
  String get arTooltipSwitchToSurfaceAnchoring => 'Switch to surface anchoring';

  @override
  String get arAnchoredToSurface => 'Anchored to tapped surface';

  @override
  String get arTapToAnchorFractal => 'Tap to anchor this fractal';

  @override
  String get arButtonReAnchor => 'Re-anchor';

  @override
  String get arButtonAnchor => 'Anchor';

  @override
  String get arSwitchToSurfaceAnchoring => 'Switch to surface anchoring';
}
