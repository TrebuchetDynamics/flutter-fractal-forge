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
  String get tabFavorites => 'Favorites';

  @override
  String get tabSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get catalogTitle => 'Fractal Catalog';

  @override
  String get catalogSearchHint => 'Search fractals';

  @override
  String get catalogSearchEmpty => 'No fractals match your search.';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get catalogClearFilters => 'Clear all';

  @override
  String catalogResultsCount(int count) {
    return '$count results';
  }

  @override
  String get viewerTitle => 'Fractal Viewer';

  @override
  String get semanticFractalCanvas => 'Interactive fractal canvas';

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
  String get actionCancel => 'Cancel';

  @override
  String get actionApply => 'Apply';

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
  String get sectionParameters => 'Parameters';

  @override
  String get sectionGlow => 'Glow';

  @override
  String get glowEnable => 'Enable';

  @override
  String get glowStrength => 'Strength';

  @override
  String get glowSoftness => 'Softness';

  @override
  String get resetView => 'Reset View';

  @override
  String get resetParams => 'Reset Params';

  @override
  String get randomize => 'Randomize';

  @override
  String get kaleidoscopeEnable => 'Enable';

  @override
  String get kaleidoscopeSectors => 'Sectors';

  @override
  String get kaleidoscopeRotation => 'Rotate';

  @override
  String get kaleidoscopeMirror => 'Mirror';

  @override
  String get kaleidoscopeMirrorAlternate => 'Alternate';

  @override
  String get kaleidoscopeMirrorDouble => 'Double';

  @override
  String get kaleidoscopeMirrorTriple => 'Triple';

  @override
  String get kaleidoscopeMirrorNone => 'None';

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
      'WebP is not encoded yet; exports use PNG fallback.';

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
  String get exportWatermark => 'Watermark';

  @override
  String get exportWatermarkHint =>
      'Add a small @FractalForge tag in the corner';

  @override
  String get exportQuoteOverlay => 'Quote overlay';

  @override
  String get exportQuoteOverlayHint =>
      'Text exports with each glyph pixel inverted against the fractal.';

  @override
  String get exportQuoteOverlayPlaceholder =>
      'Type a quote to place in the center';

  @override
  String get textOverlayTitle => 'Text overlay';

  @override
  String get tooltipTextOverlayOn => 'Text overlay on. Long press to edit.';

  @override
  String get tooltipTextOverlayOff => 'Text overlay off. Tap to add text.';

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
  String get dimensionKaleidoscope => 'Kaleidoscope';

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
  String get fractalSection2d => '2D';

  @override
  String get fractalSection3d => '3D';

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
  String get tooltipResetViewWithParams =>
      'Reset View. Long press for Reset Params';

  @override
  String get tooltipIncreaseIterationsWithDecrease =>
      'Iterations +. Long press for −';

  @override
  String get tooltipColorSchemeWithPalette =>
      'Color Scheme. Long press for palette';

  @override
  String get tooltipRandomizeWithControls =>
      'Randomize. Long press for Controls';

  @override
  String get tooltipKaleidoscopeOn => 'Kaleidoscope on';

  @override
  String get tooltipKaleidoscopeOff => 'Kaleidoscope off';

  @override
  String get tooltipCameraLooper => 'Camera looper';

  @override
  String get tooltipFractalMusicOn => 'Fractal Music on';

  @override
  String get tooltipFractalMusicOff => 'Fractal Music off';

  @override
  String get tooltipFourierOn => 'Fourier view on';

  @override
  String get tooltipFourierOff => 'Fourier view off';

  @override
  String get fourierOptionsDescription =>
      'View the current fractal in spatial and frequency domains.';

  @override
  String get fourierSettingsTitle => 'Fourier view';

  @override
  String get fourierDisplay => 'Display';

  @override
  String get fourierSplit => 'Split';

  @override
  String get fourierSpectrum => 'Spectrum';

  @override
  String get fourierResolution => 'Resolution';

  @override
  String get fourierResolutionAuto => 'Auto';

  @override
  String get fourierWindowHann => 'Window rendered image (Hann)';

  @override
  String get fourierRemoveDc => 'Remove average level (DC)';

  @override
  String get fourierMusic => 'Fourier Music';

  @override
  String get fourierMusicDescription =>
      'Use measured spectrum features to modulate Fractal Music while playback is on.';

  @override
  String get fourierOpenLab => 'Open Fractal Uncertainty Lab';

  @override
  String get fourierSpatialUnitsNote =>
      'Spatial frequencies are cycles per viewport, not Hertz.';

  @override
  String get fourierFiniteDisclaimer =>
      'Finite numerical experiment—not a mathematical proof.';

  @override
  String get fourierUnavailable => 'Fourier analysis unavailable';

  @override
  String get fourierUpdatingSpectrum => 'Updating spectrum…';

  @override
  String get fourierFrameUnavailable => 'Spectrum unavailable for this frame';

  @override
  String get fourierFrameUnavailableRetained =>
      'Spectrum unavailable for the current frame. Showing the last available result.';

  @override
  String get fourierSpectrumSemantic => 'Fourier spectrum';

  @override
  String get fourierLowPower => 'low-frequency power';

  @override
  String get fourierMidPower => 'mid-frequency power';

  @override
  String get fourierHighPower => 'high-frequency power';

  @override
  String get fourierDominantVariation => 'Dominant Fourier-energy axis';

  @override
  String get fourierNoStrongDirectionalAxis =>
      'No strong directional axis detected';

  @override
  String get fourierOrientationHorizontal => 'horizontal';

  @override
  String get fourierOrientationVertical => 'vertical';

  @override
  String get fourierOrientationDiagonal => 'diagonal';

  @override
  String get fourierDegrees => 'degrees';

  @override
  String get fourierAt => 'at';

  @override
  String get fourierPercent => 'percent';

  @override
  String get fourierEntropy => 'spectral entropy';

  @override
  String get fourierFlatness => 'spectral flatness';

  @override
  String get fourierAnisotropy => 'anisotropy';

  @override
  String get fourierFlux => 'spectral flux';

  @override
  String get fourierViewportAnalysis =>
      'Finite numerical base-field analysis of the current viewport.';

  @override
  String get fourierBaseFieldNote =>
      'Analysis replays the visible renderer\'s effective base field. Fluid, morph, celebration, and interface overlays are excluded.';

  @override
  String get fourierSpatialPane => 'Rendered spatial base field';

  @override
  String get fourierSpectrumPane => 'Sampled Fourier magnitude';

  @override
  String get uncertaintyLabTitle => 'Fractal Uncertainty Lab';

  @override
  String get uncertaintyLabIntro =>
      'Estimate how strongly a finite signal can remain concentrated in both selected spatial and Fourier masks. Spectrum coordinates are finite grid frequencies, not audible Hertz.';

  @override
  String get uncertaintyExperiment => 'Experiment';

  @override
  String get uncertaintyProductDust => 'Middle-thirds product dust';

  @override
  String get uncertaintySierpinski => 'Sierpiński carpet';

  @override
  String get uncertaintyOrthogonalLines => 'Orthogonal line pair';

  @override
  String get uncertaintyLineObstruction => 'Known orthogonal-line obstruction';

  @override
  String get uncertaintyLineObstructionExplanation =>
      'Ball porosity alone does not exclude straight frequency highways. Cohen’s higher-dimensional theorem assumes physical-space ball porosity and frequency-space line porosity across the relevant scales.';

  @override
  String get uncertaintyRecursionDepth => 'Recursion depth';

  @override
  String get uncertaintyBaseGrid => 'Base 3 grid';

  @override
  String get uncertaintySpatialMask => 'Spatial mask X';

  @override
  String get uncertaintyFourierMask => 'Fourier mask Y';

  @override
  String get uncertaintyOccupiedCells => 'occupied cells';

  @override
  String get uncertaintyTotalCells => 'total cells';

  @override
  String get uncertaintyEstimating => 'Estimating…';

  @override
  String get uncertaintyRun => 'Run finite experiment';

  @override
  String get uncertaintyUnavailable => 'Experiment unavailable';

  @override
  String get uncertaintyEstimatedNorm => 'Estimated restricted Fourier norm';

  @override
  String get uncertaintyRetainedEnergy => 'Estimated maximum retained energy';

  @override
  String get uncertaintyWorstLeakage => 'Estimated minimum leakage';

  @override
  String get uncertaintyHilbertSchmidt => 'Hilbert–Schmidt bound';

  @override
  String get uncertaintyConvergenceResidual => 'Convergence residual';

  @override
  String get uncertaintyAfterIterations => 'after iterations';

  @override
  String get uncertaintyConverged => 'converged';

  @override
  String get uncertaintyNotConverged => 'not converged';

  @override
  String get uncertaintyFiniteEstimate => 'Finite empirical estimate.';

  @override
  String get fractalMusicUnavailable =>
      'Fractal Music unavailable. Check your audio device.';

  @override
  String get shareToSocialTargets => 'Share to X / Reddit';

  @override
  String get tooltipShareImage => 'Share image';

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
  String get wallpaperSaveCopySubtitle => 'Also saves a copy to your gallery.';

  @override
  String get wallpaperApply => 'Apply';

  @override
  String get wallpaperApplied => 'Wallpaper ready';

  @override
  String get wallpaperSavedToPhotos => 'Saved to Photos';

  @override
  String get wallpaperFailed => 'Couldn’t apply wallpaper';

  @override
  String get wallpaperAppliedCopyFailed =>
      'Wallpaper ready, but the copy couldn’t be saved';

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
  String get exportActionSaveImage => 'Save image';

  @override
  String get exportActionSaveAndShare => 'Save & share';

  @override
  String get exportSaveLocationHint =>
      'Saves to Pictures/FractalForge. No storage permission prompt.';

  @override
  String get exportFormatFallbackPng => 'PNG fallback';

  @override
  String get exportSavedShareFailed =>
      'Export saved. Sharing did not open; try sharing the saved image from Photos.';

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
    return '$name fractal, $dimension';
  }

  @override
  String semanticSlider(Object label, Object value, Object min, Object max) {
    return '$label slider. Current value: $value. Minimum: $min, Maximum: $max';
  }

  @override
  String get semanticNavExplore => 'Explore tab. Browse fractal catalog.';

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
  String get semanticSplashScreen => 'Fractal Forge splash screen';

  @override
  String get splashTagline => 'Explore infinite mathematical patterns';

  @override
  String semanticOnboardingProgress(Object step, Object total) {
    return 'Onboarding progress, step $step of $total';
  }

  @override
  String get tooltipExitFullscreen => 'Exit fullscreen view';

  @override
  String get announceEnteredFullscreen => 'Entered fullscreen view';

  @override
  String get announceExitedFullscreen => 'Exited fullscreen view';

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
  String get cpuFallbackBannerMessage =>
      'CPU fallback enabled (GPU output appeared black).';

  @override
  String get looperTitle => 'Camera looper';

  @override
  String get looperSubtitle =>
      'Save camera + parameter keyframes, then preview or export a looping GIF. Max 15s.';

  @override
  String get looperSetStartHint => 'Move to a starting view, then set A.';

  @override
  String get looperSetEndHint => 'Move to the next view, then set B.';

  @override
  String looperReadyStatus(Object count) {
    return '$count keyframes ready. Preview the loop or export it.';
  }

  @override
  String get looperSetA => 'Set A';

  @override
  String get looperSetB => 'Set B';

  @override
  String looperUpdatePoint(Object label) {
    return 'Update $label';
  }

  @override
  String looperAddPoint(Object label) {
    return 'Add $label';
  }

  @override
  String looperRemovePoint(Object label) {
    return 'Remove keyframe $label';
  }

  @override
  String get looperDuration => 'Duration';

  @override
  String looperDurationValue(Object seconds) {
    return '${seconds}s / 15s max';
  }

  @override
  String looperSeconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get looperPreview => 'Preview';

  @override
  String get looperStop => 'Stop';

  @override
  String get looperExportGif => 'Export GIF';

  @override
  String get looperExportMp4 => 'Export MP4 + music';

  @override
  String get looperExportSuccess => 'Looper GIF exported';

  @override
  String get looperExportMp4Success => 'Looper MP4 with music exported';

  @override
  String looperExportFailed(Object error) {
    return 'Looper GIF export failed: $error';
  }

  @override
  String looperExportMp4Failed(Object error) {
    return 'Looper MP4 export failed: $error';
  }

  @override
  String get looperExportSavedShareFailed =>
      'Looper GIF saved. Sharing did not open; share the saved file manually.';

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
      'Simple mode — choose a quick preset, then tap Save image or Save & share.';

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
  String get homeFractalCountBadge => '966 fractals';

  @override
  String get catalogAllFractals => 'All Fractals';

  @override
  String get catalogFilterAll => 'All';

  @override
  String get catalogFilterSortOrder => 'Sort order';

  @override
  String get catalogSortByCategory => 'By Category';

  @override
  String get catalogSortAlphabetical => 'Alphabetical A-Z';

  @override
  String get catalogSortAlphabeticalShort => 'A-Z';

  @override
  String get catalogSwitchToList => 'Switch to list view';

  @override
  String get catalogSwitchToMiniatures => 'Switch to miniatures';

  @override
  String get catalogSwitchToGrid => 'Switch to grid view';

  @override
  String get catalogListView => 'List view';

  @override
  String get catalogGridView => 'Grid view';

  @override
  String get catalogFeatured => 'FEATURED';

  @override
  String get catalogFilterCategories => 'Categories';

  @override
  String get catalogResults => 'Results';

  @override
  String get catalogCategories => 'Categories';

  @override
  String get actionClearFilters => 'Clear filters';

  @override
  String get historyCurrentLocation => 'HERE';

  @override
  String get historySaveAsFavorite => 'Save as favorite';

  @override
  String get historyUnnamed => 'Unnamed';

  @override
  String get historyRename => 'Rename';

  @override
  String get historyDelete => 'Delete';

  @override
  String get navBack => 'Back';

  @override
  String get navDockZoomOut => 'Out';

  @override
  String get navDockZoomOutTooltip => 'Zoom out';

  @override
  String get navDockReset => 'Reset';

  @override
  String get navDockResetTooltip => 'Reset view';

  @override
  String get navDockZoomIn => 'In';

  @override
  String get navDockZoomInTooltip => 'Zoom in';

  @override
  String get navDockRandom => 'Random';

  @override
  String navDockQuickNavLabel(Object zoom) {
    return 'Quick navigation. Current zoom $zoom. Actions: zoom out, reset view, zoom in, random fractal.';
  }

  @override
  String get tooltipMoreOptions => 'More options';

  @override
  String get viewerMoreActionsHint => 'Opens secondary viewer actions.';

  @override
  String get viewerSecondaryActionHint =>
      'Shift+Enter opens the secondary action.';

  @override
  String get tooltipFullscreen => 'Fullscreen view';

  @override
  String semanticSliderAdjust(Object min, Object max) {
    return 'Adjust from $min to $max';
  }

  @override
  String semanticSectionHeader(Object name, Object count) {
    return '$name section, $count fractals';
  }

  @override
  String get semanticFeaturedSection => 'Featured fractals carousel';

  @override
  String semanticControlsSectionHeader(Object title) {
    return '$title controls section';
  }

  @override
  String get tooltipReportFractal => 'Report fractal';

  @override
  String get randomOptionsTitle => 'Random options';

  @override
  String get randomOptionsSubtitle =>
      'Jump to a new fractal or keep this one and reshape its parameters.';

  @override
  String get randomOptionsCatalogDescription =>
      'Switch to another catalog entry.';

  @override
  String get randomOptionsParamsDescription =>
      'Stay on this fractal and randomize its controls.';

  @override
  String get exportOptionsSubtitleWithWallpaper =>
      'Save, share, or fit the current render to your device.';

  @override
  String get exportOptionsSubtitle => 'Save or share the current render.';

  @override
  String get exportOptionsExportDescription =>
      'Choose resolution and transparent-background options.';

  @override
  String get exportOptionsLinkDescription =>
      'Copy a replayable link to this exact view.';

  @override
  String get exportOptionsImageDescription =>
      'Render an image and send it to installed apps.';

  @override
  String get exportOptionsWallpaperDescription =>
      'Set this view as your home or lock screen wallpaper.';

  @override
  String get kaleidoscopeOptionsTitle => 'Kaleidoscope sections';

  @override
  String get kaleidoscopeOptionsSubtitle =>
      'Pick a symmetry count and mirror behavior for this view.';

  @override
  String get kaleidoscopeWedgeCount => 'Wedge count';

  @override
  String get kaleidoscopeMirrorWedges => 'Mirror wedges';

  @override
  String get kaleidoscopeMirrorWedgesDescription =>
      'Reflect each wedge for sharper radial symmetry.';

  @override
  String get hudPalette => 'Palette';

  @override
  String get hudKaleidoscope => 'Kaleidoscope';

  @override
  String get hudRotation => 'Rotation';

  @override
  String get hudFluidMode => 'Fluid mode';

  @override
  String get hudFluidIntensity => 'Fluid intensity';

  @override
  String get hudResetViewLabel => 'View';

  @override
  String get hudResetParamsLabel => 'Params';

  @override
  String get hudRandomizeTooltip => 'Randomize parameters';

  @override
  String get hudSemanticKaleidoscopeSectors => 'Kaleidoscope sectors';

  @override
  String get hudSemanticKaleidoscopeRotation => 'Kaleidoscope rotation';

  @override
  String get palettePickerSubtitle => 'Choose a palette for this render.';

  @override
  String get settingsAccessibilitySubtitle =>
      'High contrast, reduced motion, large targets';

  @override
  String get settingsPaletteSubtitle => 'Customize color palettes';

  @override
  String get settingsFormulaLab => 'Formula Lab';

  @override
  String get settingsFormulaLabSubtitle =>
      'Write & preview custom FRM formulas';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsColorTheme => 'Color Theme';

  @override
  String get settingsColorThemeSubtitle =>
      'Choose a contrast and surface style.';

  @override
  String get settingsAboutBlurb =>
      'GPU-accelerated exploration of 966 production fractals, with deep zoom and real-time rendering.';

  @override
  String get settingsSourceCode => 'Source code';

  @override
  String get settingsSourceCodeSubtitle => 'View Fractal Forge on GitHub ↗';

  @override
  String get settingsSourceCodeOpenFailed => 'Unable to open source code.';

  @override
  String get frmFormulaFieldLabel => 'FRM formula';

  @override
  String get frmRender => 'Render';

  @override
  String get frmTapRenderToPreview => 'Tap Render to preview';

  @override
  String get frmSyntaxHelp =>
      'Supports + - * / ^, functions (sqr, conj, exp, sin, …) and (re, im) literals with variables pixel / z / c. Escape defaults to |z|² > 4; add a line like cabs2(z) <= 4 to set your own.';

  @override
  String get debugReportTitle => 'GPU Debug Report';

  @override
  String debugReportSavedReport(Object path) {
    return 'Saved report: $path';
  }

  @override
  String debugReportSavedScreenshot(Object path) {
    return 'Saved screenshot: $path';
  }

  @override
  String get debugReportCopiedJson =>
      'Copied GPU debug JSON to clipboard. Paste it into Telegram.';

  @override
  String fractalReportSaved(Object path) {
    return 'Saved report: $path';
  }

  @override
  String fractalReportFailed(Object error) {
    return 'Report failed: $error';
  }

  @override
  String get reportDialogTitle => 'Report rendering issue';

  @override
  String get reportDialogSymptoms => 'Pick every symptom you see';

  @override
  String get reportDialogSymptomsHint =>
      'This saves the current view, params, and tags.';

  @override
  String get reportDialogNotes => 'Notes';

  @override
  String get reportDialogNotesHint => 'Optional details for the fix pass';

  @override
  String get reportDialogSave => 'Save report';

  @override
  String get reportDialogCopyJsonTitle => 'Copy report JSON';

  @override
  String get reportDialogCopiedJson => 'Report JSON copied';

  @override
  String get reportTagLowPerformance => 'Low performance';

  @override
  String get reportTagWeakDeepZoom => 'Weak deep zoom';

  @override
  String get reportTagLowDetail => 'Low detail';

  @override
  String get reportTagNoImage => 'No image';

  @override
  String get reportTagBadInitialView => 'Bad initial view';

  @override
  String get reportTagBadDefaultParams => 'Bad default params';

  @override
  String get reportTagNeedsMoreControlParams => 'Needs more Control Params';

  @override
  String get reportTagRandomizeBreaks => 'Randomize breaks';

  @override
  String get reportTagRemoveCandidate => 'Remove candidate';

  @override
  String get reportTagBadThumbnail => 'Bad thumbnail';

  @override
  String get reportTagWrongFractal => 'Wrong fractal';

  @override
  String get reportTagMissingShader => 'Missing shader';

  @override
  String get reportTagOther => 'Other';
}
