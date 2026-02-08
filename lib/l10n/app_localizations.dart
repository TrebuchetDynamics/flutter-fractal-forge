import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Fractals'**
  String get appTitle;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabAr.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get tabAr;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Fractal Catalog'**
  String get catalogTitle;

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fractals'**
  String get catalogSearchHint;

  /// No description provided for @catalogSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fractals match your search.'**
  String get catalogSearchEmpty;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @viewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Fractal Viewer'**
  String get viewerTitle;

  /// No description provided for @controlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controlsTitle;

  /// No description provided for @presetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetsTitle;

  /// No description provided for @builtInPresets.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtInPresets;

  /// No description provided for @userPresets.
  ///
  /// In en, this message translates to:
  /// **'Your Presets'**
  String get userPresets;

  /// No description provided for @loadingPresets.
  ///
  /// In en, this message translates to:
  /// **'Loading presets…'**
  String get loadingPresets;

  /// No description provided for @noUserPresets.
  ///
  /// In en, this message translates to:
  /// **'No saved presets yet.'**
  String get noUserPresets;

  /// No description provided for @presetsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load presets.'**
  String get presetsLoadFailed;

  /// No description provided for @savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get savePreset;

  /// No description provided for @presetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetNameHint;

  /// No description provided for @presetSaved.
  ///
  /// In en, this message translates to:
  /// **'Preset saved'**
  String get presetSaved;

  /// No description provided for @presetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a preset name.'**
  String get presetNameRequired;

  /// No description provided for @presetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save preset: {error}'**
  String presetSaveFailed(Object error);

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset View'**
  String get resetView;

  /// No description provided for @resetParams.
  ///
  /// In en, this message translates to:
  /// **'Reset Params'**
  String get resetParams;

  /// No description provided for @randomize.
  ///
  /// In en, this message translates to:
  /// **'Randomize'**
  String get randomize;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportQuickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get exportQuickPresets;

  /// No description provided for @exportPresetSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get exportPresetSocial;

  /// No description provided for @exportPresetHighQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality'**
  String get exportPresetHighQuality;

  /// No description provided for @exportPresetWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get exportPresetWeb;

  /// No description provided for @exportPresetTransparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get exportPresetTransparent;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormat;

  /// No description provided for @exportFormatHintPng.
  ///
  /// In en, this message translates to:
  /// **'Lossless quality, supports transparency. Best for editing.'**
  String get exportFormatHintPng;

  /// No description provided for @exportFormatHintJpg.
  ///
  /// In en, this message translates to:
  /// **'Smaller file size, great for sharing. No transparency.'**
  String get exportFormatHintJpg;

  /// No description provided for @exportFormatHintWebp.
  ///
  /// In en, this message translates to:
  /// **'Modern format with excellent compression. Wide support.'**
  String get exportFormatHintWebp;

  /// No description provided for @exportResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get exportResolution;

  /// No description provided for @exportWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get exportWidth;

  /// No description provided for @exportHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get exportHeight;

  /// No description provided for @exportQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get exportQuality;

  /// No description provided for @exportAdvancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get exportAdvancedOptions;

  /// No description provided for @exportTransparentBg.
  ///
  /// In en, this message translates to:
  /// **'Transparent Background'**
  String get exportTransparentBg;

  /// No description provided for @exportTransparentBgHint.
  ///
  /// In en, this message translates to:
  /// **'Remove the background for overlay use'**
  String get exportTransparentBgHint;

  /// No description provided for @exportEmbedMetadata.
  ///
  /// In en, this message translates to:
  /// **'Embed Metadata'**
  String get exportEmbedMetadata;

  /// No description provided for @exportEmbedMetadataHint.
  ///
  /// In en, this message translates to:
  /// **'Include fractal parameters in the image file'**
  String get exportEmbedMetadataHint;

  /// No description provided for @exportScreenResolution.
  ///
  /// In en, this message translates to:
  /// **'Screen size'**
  String get exportScreenResolution;

  /// No description provided for @exportSummary.
  ///
  /// In en, this message translates to:
  /// **'Export Summary'**
  String get exportSummary;

  /// No description provided for @exportNow.
  ///
  /// In en, this message translates to:
  /// **'Export Now'**
  String get exportNow;

  /// No description provided for @exportPng.
  ///
  /// In en, this message translates to:
  /// **'PNG'**
  String get exportPng;

  /// No description provided for @exportTransparentPng.
  ///
  /// In en, this message translates to:
  /// **'Transparent PNG'**
  String get exportTransparentPng;

  /// No description provided for @exportArScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Baked AR Screenshot'**
  String get exportArScreenshot;

  /// No description provided for @exportArVideo.
  ///
  /// In en, this message translates to:
  /// **'Baked AR Video'**
  String get exportArVideo;

  /// No description provided for @exportArVideoStub.
  ///
  /// In en, this message translates to:
  /// **'AR video export is scaffolded but not baked yet.'**
  String get exportArVideoStub;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Export saved'**
  String get exportSaved;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenSettings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @loadingShaders.
  ///
  /// In en, this message translates to:
  /// **'Loading shaders...'**
  String get loadingShaders;

  /// No description provided for @moduleMandelbrot.
  ///
  /// In en, this message translates to:
  /// **'Mandelbrot'**
  String get moduleMandelbrot;

  /// No description provided for @moduleJulia.
  ///
  /// In en, this message translates to:
  /// **'Julia'**
  String get moduleJulia;

  /// No description provided for @moduleBurningShip.
  ///
  /// In en, this message translates to:
  /// **'Burning Ship'**
  String get moduleBurningShip;

  /// No description provided for @modulePhoenix.
  ///
  /// In en, this message translates to:
  /// **'Phoenix'**
  String get modulePhoenix;

  /// No description provided for @moduleMandelbulb.
  ///
  /// In en, this message translates to:
  /// **'Mandelbulb'**
  String get moduleMandelbulb;

  /// No description provided for @dimension2d.
  ///
  /// In en, this message translates to:
  /// **'2D'**
  String get dimension2d;

  /// No description provided for @dimension3d.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get dimension3d;

  /// No description provided for @paramIterations.
  ///
  /// In en, this message translates to:
  /// **'Iterations'**
  String get paramIterations;

  /// No description provided for @paramSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get paramSteps;

  /// No description provided for @paramBailout.
  ///
  /// In en, this message translates to:
  /// **'Bailout'**
  String get paramBailout;

  /// No description provided for @paramPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get paramPower;

  /// No description provided for @paramColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get paramColorScheme;

  /// No description provided for @paramFractalType.
  ///
  /// In en, this message translates to:
  /// **'Fractal Type'**
  String get paramFractalType;

  /// No description provided for @paramJuliaCReal.
  ///
  /// In en, this message translates to:
  /// **'Julia C (Real)'**
  String get paramJuliaCReal;

  /// No description provided for @paramJuliaCImag.
  ///
  /// In en, this message translates to:
  /// **'Julia C (Imag)'**
  String get paramJuliaCImag;

  /// No description provided for @paramPhoenixCReal.
  ///
  /// In en, this message translates to:
  /// **'Phoenix C (Real)'**
  String get paramPhoenixCReal;

  /// No description provided for @paramPhoenixCImag.
  ///
  /// In en, this message translates to:
  /// **'Phoenix C (Imag)'**
  String get paramPhoenixCImag;

  /// No description provided for @paramPhoenixP.
  ///
  /// In en, this message translates to:
  /// **'Phoenix P (Memory)'**
  String get paramPhoenixP;

  /// No description provided for @paramOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get paramOpacity;

  /// No description provided for @paramLockOverlay.
  ///
  /// In en, this message translates to:
  /// **'Lock Overlay'**
  String get paramLockOverlay;

  /// No description provided for @paramTransparentBg.
  ///
  /// In en, this message translates to:
  /// **'Transparent Background'**
  String get paramTransparentBg;

  /// No description provided for @arQualityPreset.
  ///
  /// In en, this message translates to:
  /// **'AR Quality'**
  String get arQualityPreset;

  /// No description provided for @arQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get arQualityLow;

  /// No description provided for @arQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get arQualityMedium;

  /// No description provided for @arQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get arQualityHigh;

  /// No description provided for @arTitle.
  ///
  /// In en, this message translates to:
  /// **'AR Overlay'**
  String get arTitle;

  /// No description provided for @arSelectFractal.
  ///
  /// In en, this message translates to:
  /// **'Fractal'**
  String get arSelectFractal;

  /// No description provided for @fractalSection2d.
  ///
  /// In en, this message translates to:
  /// **'2D'**
  String get fractalSection2d;

  /// No description provided for @fractalSection3d.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get fractalSection3d;

  /// No description provided for @arPermissionRequest.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for AR mode.'**
  String get arPermissionRequest;

  /// No description provided for @arPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied.'**
  String get arPermissionDenied;

  /// No description provided for @arCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available.'**
  String get arCameraUnavailable;

  /// No description provided for @arCameraUnavailableHelp.
  ///
  /// In en, this message translates to:
  /// **'Make sure another app isn’t using the camera, then try again.'**
  String get arCameraUnavailableHelp;

  /// No description provided for @arOverlayOnlyExport.
  ///
  /// In en, this message translates to:
  /// **'Overlay-only PNG'**
  String get arOverlayOnlyExport;

  /// No description provided for @arBakedScreenshotExport.
  ///
  /// In en, this message translates to:
  /// **'Baked camera + overlay'**
  String get arBakedScreenshotExport;

  /// No description provided for @arVideoExport.
  ///
  /// In en, this message translates to:
  /// **'Record AR Video'**
  String get arVideoExport;

  /// No description provided for @arVideoExportFailed.
  ///
  /// In en, this message translates to:
  /// **'AR video export failed.'**
  String get arVideoExportFailed;

  /// No description provided for @arVideoFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg unavailable or failed. Exported a low-FPS GIF fallback (larger file, no audio).'**
  String get arVideoFallbackNotice;

  /// No description provided for @arDuration5.
  ///
  /// In en, this message translates to:
  /// **'5s'**
  String get arDuration5;

  /// No description provided for @arDuration10.
  ///
  /// In en, this message translates to:
  /// **'10s'**
  String get arDuration10;

  /// No description provided for @arDuration15.
  ///
  /// In en, this message translates to:
  /// **'15s'**
  String get arDuration15;

  /// No description provided for @colorFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get colorFire;

  /// No description provided for @colorOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get colorOcean;

  /// No description provided for @colorPsychedelic.
  ///
  /// In en, this message translates to:
  /// **'Psychedelic'**
  String get colorPsychedelic;

  /// No description provided for @colorGrayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get colorGrayscale;

  /// No description provided for @colorPhoenix.
  ///
  /// In en, this message translates to:
  /// **'Phoenix'**
  String get colorPhoenix;

  /// No description provided for @fractalTypeMandelbulb.
  ///
  /// In en, this message translates to:
  /// **'Mandelbulb'**
  String get fractalTypeMandelbulb;

  /// No description provided for @fractalTypeMandelbox.
  ///
  /// In en, this message translates to:
  /// **'Mandelbox'**
  String get fractalTypeMandelbox;

  /// No description provided for @fractalTypeJulia.
  ///
  /// In en, this message translates to:
  /// **'Julia'**
  String get fractalTypeJulia;

  /// No description provided for @fractalTypeSierpinski.
  ///
  /// In en, this message translates to:
  /// **'Sierpinski'**
  String get fractalTypeSierpinski;

  /// No description provided for @tooltipOpenControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get tooltipOpenControls;

  /// No description provided for @tooltipOpenPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get tooltipOpenPresets;

  /// No description provided for @tooltipExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get tooltipExport;

  /// No description provided for @presetDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get presetDefault;

  /// No description provided for @presetClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get presetClassic;

  /// No description provided for @presetSoftGlow.
  ///
  /// In en, this message translates to:
  /// **'Soft Glow'**
  String get presetSoftGlow;

  /// No description provided for @presetPsychedelic.
  ///
  /// In en, this message translates to:
  /// **'Psychedelic'**
  String get presetPsychedelic;

  /// No description provided for @presetDeepBloom.
  ///
  /// In en, this message translates to:
  /// **'Deep Bloom'**
  String get presetDeepBloom;

  /// No description provided for @arStyleNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get arStyleNeon;

  /// No description provided for @arStyleSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get arStyleSoft;

  /// No description provided for @arStyleMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get arStyleMono;

  /// No description provided for @arStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get arStyleTitle;

  /// No description provided for @arShowGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get arShowGrid;

  /// No description provided for @arShowOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get arShowOutline;

  /// No description provided for @tooltipExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get tooltipExpand;

  /// No description provided for @tooltipCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get tooltipCollapse;

  /// No description provided for @errorOverlayNotReady.
  ///
  /// In en, this message translates to:
  /// **'Overlay not ready'**
  String get errorOverlayNotReady;

  /// No description provided for @errorCameraNotReady.
  ///
  /// In en, this message translates to:
  /// **'Camera not ready'**
  String get errorCameraNotReady;

  /// No description provided for @shaderLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shader'**
  String get shaderLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
