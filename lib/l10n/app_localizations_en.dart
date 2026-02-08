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
}
