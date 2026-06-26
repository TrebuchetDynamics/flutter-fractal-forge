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
  /// **'Fractal Forge'**
  String get appTitle;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

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

  /// No description provided for @catalogClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get catalogClearFilters;

  /// No description provided for @catalogResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String catalogResultsCount(int count);

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

  /// No description provided for @batchExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch Export'**
  String get batchExportTitle;

  /// No description provided for @batchExportAllPresets.
  ///
  /// In en, this message translates to:
  /// **'Export all presets'**
  String get batchExportAllPresets;

  /// No description provided for @batchExportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get batchExportPreparing;

  /// No description provided for @batchExportCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get batchExportCancelling;

  /// No description provided for @batchExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get batchExportCancelled;

  /// No description provided for @batchExportDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get batchExportDone;

  /// No description provided for @batchExportNoPresets.
  ///
  /// In en, this message translates to:
  /// **'No presets to export.'**
  String get batchExportNoPresets;

  /// No description provided for @batchExportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to:'**
  String get batchExportSavedTo;

  /// No description provided for @batchExportContactSheet.
  ///
  /// In en, this message translates to:
  /// **'Contact sheet'**
  String get batchExportContactSheet;

  /// No description provided for @batchExportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get batchExportCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

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

  /// No description provided for @sectionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get sectionActions;

  /// No description provided for @sectionParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get sectionParameters;

  /// No description provided for @sectionGlow.
  ///
  /// In en, this message translates to:
  /// **'Glow'**
  String get sectionGlow;

  /// No description provided for @glowEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get glowEnable;

  /// No description provided for @glowStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get glowStrength;

  /// No description provided for @glowSoftness.
  ///
  /// In en, this message translates to:
  /// **'Softness'**
  String get glowSoftness;

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

  /// No description provided for @kaleidoscopeEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get kaleidoscopeEnable;

  /// No description provided for @kaleidoscopeSectors.
  ///
  /// In en, this message translates to:
  /// **'Sectors'**
  String get kaleidoscopeSectors;

  /// No description provided for @kaleidoscopeRotation.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get kaleidoscopeRotation;

  /// No description provided for @kaleidoscopeMirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get kaleidoscopeMirror;

  /// No description provided for @kaleidoscopeMirrorAlternate.
  ///
  /// In en, this message translates to:
  /// **'Alternate'**
  String get kaleidoscopeMirrorAlternate;

  /// No description provided for @kaleidoscopeMirrorDouble.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get kaleidoscopeMirrorDouble;

  /// No description provided for @kaleidoscopeMirrorTriple.
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get kaleidoscopeMirrorTriple;

  /// No description provided for @kaleidoscopeMirrorNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get kaleidoscopeMirrorNone;

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
  /// **'WebP is not encoded yet; exports use PNG fallback.'**
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

  /// No description provided for @dimensionKaleidoscope.
  ///
  /// In en, this message translates to:
  /// **'Kaleidoscope'**
  String get dimensionKaleidoscope;

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

  /// No description provided for @tooltipWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Set as Wallpaper'**
  String get tooltipWallpaper;

  /// No description provided for @tooltipResetViewWithParams.
  ///
  /// In en, this message translates to:
  /// **'Reset View. Long press for Reset Params'**
  String get tooltipResetViewWithParams;

  /// No description provided for @tooltipIncreaseIterationsWithDecrease.
  ///
  /// In en, this message translates to:
  /// **'Iterations +. Long press for −'**
  String get tooltipIncreaseIterationsWithDecrease;

  /// No description provided for @tooltipColorSchemeWithPalette.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme. Long press for palette'**
  String get tooltipColorSchemeWithPalette;

  /// No description provided for @tooltipKaleidoscopeOn.
  ///
  /// In en, this message translates to:
  /// **'Kaleidoscope on'**
  String get tooltipKaleidoscopeOn;

  /// No description provided for @tooltipKaleidoscopeOff.
  ///
  /// In en, this message translates to:
  /// **'Kaleidoscope off'**
  String get tooltipKaleidoscopeOff;

  /// No description provided for @tooltipCameraLooper.
  ///
  /// In en, this message translates to:
  /// **'Camera looper'**
  String get tooltipCameraLooper;

  /// No description provided for @shareToSocialTargets.
  ///
  /// In en, this message translates to:
  /// **'Share to X / Reddit'**
  String get shareToSocialTargets;

  /// No description provided for @wallpaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get wallpaperTitle;

  /// No description provided for @wallpaperAndroidNote.
  ///
  /// In en, this message translates to:
  /// **'Exports at your device’s native resolution and sets it as wallpaper.'**
  String get wallpaperAndroidNote;

  /// No description provided for @wallpaperIosNote.
  ///
  /// In en, this message translates to:
  /// **'iOS doesn’t allow apps to set wallpapers directly. We’ll save the image to Photos so you can set it from there.'**
  String get wallpaperIosNote;

  /// No description provided for @wallpaperTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get wallpaperTarget;

  /// No description provided for @wallpaperTargetHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get wallpaperTargetHome;

  /// No description provided for @wallpaperTargetLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get wallpaperTargetLock;

  /// No description provided for @wallpaperTargetBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get wallpaperTargetBoth;

  /// No description provided for @wallpaperPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get wallpaperPresets;

  /// No description provided for @wallpaperPresetPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get wallpaperPresetPlain;

  /// No description provided for @wallpaperPresetHome.
  ///
  /// In en, this message translates to:
  /// **'Home optimized'**
  String get wallpaperPresetHome;

  /// No description provided for @wallpaperPresetLock.
  ///
  /// In en, this message translates to:
  /// **'Lock optimized'**
  String get wallpaperPresetLock;

  /// No description provided for @wallpaperSaveCopy.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get wallpaperSaveCopy;

  /// No description provided for @wallpaperSaveCopySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Also saves a copy to your gallery.'**
  String get wallpaperSaveCopySubtitle;

  /// No description provided for @wallpaperApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get wallpaperApply;

  /// No description provided for @wallpaperApplied.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper ready'**
  String get wallpaperApplied;

  /// No description provided for @wallpaperSavedToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos'**
  String get wallpaperSavedToPhotos;

  /// No description provided for @wallpaperFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t apply wallpaper'**
  String get wallpaperFailed;

  /// No description provided for @wallpaperFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t apply wallpaper: {error}'**
  String wallpaperFailedWithError(Object error);

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

  /// No description provided for @contextMenuResetView.
  ///
  /// In en, this message translates to:
  /// **'Reset View'**
  String get contextMenuResetView;

  /// No description provided for @contextMenuOpenControls.
  ///
  /// In en, this message translates to:
  /// **'Open Controls'**
  String get contextMenuOpenControls;

  /// No description provided for @contextMenuOpenPresets.
  ///
  /// In en, this message translates to:
  /// **'Open Presets'**
  String get contextMenuOpenPresets;

  /// No description provided for @contextMenuRandomize.
  ///
  /// In en, this message translates to:
  /// **'Randomize'**
  String get contextMenuRandomize;

  /// No description provided for @contextMenuExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get contextMenuExport;

  /// No description provided for @gestureDoubleTapReset.
  ///
  /// In en, this message translates to:
  /// **'View reset'**
  String get gestureDoubleTapReset;

  /// No description provided for @exportActionSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get exportActionSaveImage;

  /// No description provided for @exportActionSaveAndShare.
  ///
  /// In en, this message translates to:
  /// **'Save & share'**
  String get exportActionSaveAndShare;

  /// No description provided for @exportSaveLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Saves to Pictures/FractalForge. No storage permission prompt.'**
  String get exportSaveLocationHint;

  /// No description provided for @exportFormatFallbackPng.
  ///
  /// In en, this message translates to:
  /// **'PNG fallback'**
  String get exportFormatFallbackPng;

  /// No description provided for @exportSavedShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Export saved. Sharing did not open; try sharing the saved image from Photos.'**
  String get exportSavedShareFailed;

  /// No description provided for @accessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

  /// No description provided for @accessibilityHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get accessibilityHighContrast;

  /// No description provided for @accessibilityHighContrastHint.
  ///
  /// In en, this message translates to:
  /// **'Use bright colors with maximum contrast'**
  String get accessibilityHighContrastHint;

  /// No description provided for @accessibilityReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduced Motion'**
  String get accessibilityReducedMotion;

  /// No description provided for @accessibilityReducedMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Minimize animations and transitions'**
  String get accessibilityReducedMotionHint;

  /// No description provided for @accessibilityLargeTargets.
  ///
  /// In en, this message translates to:
  /// **'Large Touch Targets'**
  String get accessibilityLargeTargets;

  /// No description provided for @accessibilityLargeTargetsHint.
  ///
  /// In en, this message translates to:
  /// **'Increase size of interactive elements'**
  String get accessibilityLargeTargetsHint;

  /// No description provided for @accessibilityScreenReaderActive.
  ///
  /// In en, this message translates to:
  /// **'Screen reader is active'**
  String get accessibilityScreenReaderActive;

  /// No description provided for @soundEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffectsTitle;

  /// No description provided for @soundEffectsEnabled.
  ///
  /// In en, this message translates to:
  /// **'UI Sounds'**
  String get soundEffectsEnabled;

  /// No description provided for @soundEffectsEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Play subtle sounds for button taps and transitions'**
  String get soundEffectsEnabledHint;

  /// No description provided for @soundEffectsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get soundEffectsVolume;

  /// No description provided for @semanticFractalViewer.
  ///
  /// In en, this message translates to:
  /// **'Interactive fractal viewer. Pinch to zoom, drag to pan.'**
  String get semanticFractalViewer;

  /// No description provided for @semanticFractalCard.
  ///
  /// In en, this message translates to:
  /// **'{name} fractal, {dimension}. Double tap to open.'**
  String semanticFractalCard(Object name, Object dimension);

  /// No description provided for @semanticSlider.
  ///
  /// In en, this message translates to:
  /// **'{label} slider. Current value: {value}. Minimum: {min}, Maximum: {max}'**
  String semanticSlider(Object label, Object value, Object min, Object max);

  /// No description provided for @semanticNavExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore tab. Browse fractal catalog.'**
  String get semanticNavExplore;

  /// No description provided for @semanticBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go back to previous screen'**
  String get semanticBackButton;

  /// No description provided for @semanticCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close this dialog'**
  String get semanticCloseButton;

  /// No description provided for @semanticSearchField.
  ///
  /// In en, this message translates to:
  /// **'Search fractals by name'**
  String get semanticSearchField;

  /// No description provided for @semanticExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export current fractal as image'**
  String get semanticExportButton;

  /// No description provided for @semanticControlsButton.
  ///
  /// In en, this message translates to:
  /// **'Open fractal parameter controls'**
  String get semanticControlsButton;

  /// No description provided for @semanticPresetsButton.
  ///
  /// In en, this message translates to:
  /// **'Open saved presets'**
  String get semanticPresetsButton;

  /// No description provided for @semanticRandomizeButton.
  ///
  /// In en, this message translates to:
  /// **'Randomize all fractal parameters'**
  String get semanticRandomizeButton;

  /// No description provided for @semanticResetViewButton.
  ///
  /// In en, this message translates to:
  /// **'Reset view to default position'**
  String get semanticResetViewButton;

  /// No description provided for @semanticResetParamsButton.
  ///
  /// In en, this message translates to:
  /// **'Reset all parameters to defaults'**
  String get semanticResetParamsButton;

  /// No description provided for @semanticZoomLevel.
  ///
  /// In en, this message translates to:
  /// **'Zoom level: {percent} percent'**
  String semanticZoomLevel(Object percent);

  /// No description provided for @semanticLoadingShaders.
  ///
  /// In en, this message translates to:
  /// **'Loading fractal shaders, please wait'**
  String get semanticLoadingShaders;

  /// No description provided for @semanticExportProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting image, {percent} percent complete'**
  String semanticExportProgress(Object percent);

  /// No description provided for @semanticPresetItem.
  ///
  /// In en, this message translates to:
  /// **'{name} preset. Double tap to apply.'**
  String semanticPresetItem(Object name);

  /// No description provided for @semanticToggleOn.
  ///
  /// In en, this message translates to:
  /// **'{label}, currently on. Double tap to turn off.'**
  String semanticToggleOn(Object label);

  /// No description provided for @semanticToggleOff.
  ///
  /// In en, this message translates to:
  /// **'{label}, currently off. Double tap to turn on.'**
  String semanticToggleOff(Object label);

  /// No description provided for @announceFractalLoaded.
  ///
  /// In en, this message translates to:
  /// **'{name} fractal loaded'**
  String announceFractalLoaded(Object name);

  /// No description provided for @announcePresetApplied.
  ///
  /// In en, this message translates to:
  /// **'Preset {name} applied'**
  String announcePresetApplied(Object name);

  /// No description provided for @announceExportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get announceExportComplete;

  /// No description provided for @announceViewReset.
  ///
  /// In en, this message translates to:
  /// **'View reset to default'**
  String get announceViewReset;

  /// No description provided for @announceParamsRandomized.
  ///
  /// In en, this message translates to:
  /// **'Parameters randomized'**
  String get announceParamsRandomized;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @semanticSplashScreen.
  ///
  /// In en, this message translates to:
  /// **'Fractal Forge splash screen'**
  String get semanticSplashScreen;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Explore infinite mathematical patterns'**
  String get splashTagline;

  /// No description provided for @semanticOnboardingProgress.
  ///
  /// In en, this message translates to:
  /// **'Onboarding progress, step {step} of {total}'**
  String semanticOnboardingProgress(Object step, Object total);

  /// No description provided for @semanticSkipOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Skip onboarding'**
  String get semanticSkipOnboarding;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fractal Forge'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore infinite mathematical beauty through 350+ interactive fractals with GPU-accelerated rendering — from Mandelbrot sets to strange attractors.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingWelcomeHighlight1.
  ///
  /// In en, this message translates to:
  /// **'Pan and pinch to navigate with deep zoom and infinite precision'**
  String get onboardingWelcomeHighlight1;

  /// No description provided for @onboardingWelcomeHighlight2.
  ///
  /// In en, this message translates to:
  /// **'Discover structure in Mandelbrot, Julia, Newton and 350+ fractal types'**
  String get onboardingWelcomeHighlight2;

  /// No description provided for @onboardingWelcomeHighlight3.
  ///
  /// In en, this message translates to:
  /// **'GPU-accelerated rendering for smooth, real-time exploration'**
  String get onboardingWelcomeHighlight3;

  /// No description provided for @onboardingCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create, Export & Share'**
  String get onboardingCreateTitle;

  /// No description provided for @onboardingCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust parameters in real time and export stunning high-resolution images to share.'**
  String get onboardingCreateDescription;

  /// No description provided for @onboardingCreateHighlight1.
  ///
  /// In en, this message translates to:
  /// **'Real-time parameter controls with 60+ colour schemes'**
  String get onboardingCreateHighlight1;

  /// No description provided for @onboardingCreateHighlight2.
  ///
  /// In en, this message translates to:
  /// **'Export to PNG and share — perfect for art, presentations and study'**
  String get onboardingCreateHighlight2;

  /// No description provided for @onboardingFractalTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Fractal Types'**
  String get onboardingFractalTypesTitle;

  /// No description provided for @onboardingFractalTypesDescription.
  ///
  /// In en, this message translates to:
  /// **'From classic 2D fractals to stunning 3D Mandelbulb, explore a variety of mathematical art.'**
  String get onboardingFractalTypesDescription;

  /// No description provided for @onboardingGesturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Intuitive Controls'**
  String get onboardingGesturesTitle;

  /// No description provided for @onboardingGesturesDescription.
  ///
  /// In en, this message translates to:
  /// **'Navigate fractals with simple, natural gestures.'**
  String get onboardingGesturesDescription;

  /// No description provided for @onboardingGesturePan.
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get onboardingGesturePan;

  /// No description provided for @onboardingGesturePanDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag with one finger to move around'**
  String get onboardingGesturePanDesc;

  /// No description provided for @onboardingGestureZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get onboardingGestureZoom;

  /// No description provided for @onboardingGestureZoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom in and out'**
  String get onboardingGestureZoomDesc;

  /// No description provided for @onboardingGestureRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get onboardingGestureRotate;

  /// No description provided for @onboardingGestureRotateDesc.
  ///
  /// In en, this message translates to:
  /// **'Two-finger rotate for 3D fractals'**
  String get onboardingGestureRotateDesc;

  /// No description provided for @onboardingGestureDoubleTap.
  ///
  /// In en, this message translates to:
  /// **'Double Tap'**
  String get onboardingGestureDoubleTap;

  /// No description provided for @onboardingGestureDoubleTapDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick reset to default view'**
  String get onboardingGestureDoubleTapDesc;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Powerful Features'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeaturesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create, customize, and share your fractal creations.'**
  String get onboardingFeaturesDescription;

  /// No description provided for @onboardingFeaturePresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get onboardingFeaturePresets;

  /// No description provided for @onboardingFeaturePresetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save and load your favorite configurations'**
  String get onboardingFeaturePresetsDesc;

  /// No description provided for @onboardingFeatureExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get onboardingFeatureExport;

  /// No description provided for @onboardingFeatureExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Save high-quality images in multiple formats'**
  String get onboardingFeatureExportDesc;

  /// No description provided for @tooltipExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit fullscreen view'**
  String get tooltipExitFullscreen;

  /// No description provided for @announceEnteredFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Entered fullscreen view'**
  String get announceEnteredFullscreen;

  /// No description provided for @announceExitedFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exited fullscreen view'**
  String get announceExitedFullscreen;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Fractal'**
  String get shareTitle;

  /// No description provided for @shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check out this {fractalName} fractal I created!'**
  String shareSubtitle(Object fractalName);

  /// No description provided for @tooltipShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tooltipShare;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this {fractalName} fractal! {link}'**
  String shareMessage(Object fractalName, Object link);

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'{fractalName} Fractal - Flutter Fractals'**
  String shareSubject(Object fractalName);

  /// No description provided for @videoExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Video'**
  String get videoExportTitle;

  /// No description provided for @videoPresetQuickGif.
  ///
  /// In en, this message translates to:
  /// **'Quick GIF'**
  String get videoPresetQuickGif;

  /// No description provided for @videoPresetSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get videoPresetSocial;

  /// No description provided for @videoPresetHighQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality'**
  String get videoPresetHighQuality;

  /// No description provided for @videoPresetLoop.
  ///
  /// In en, this message translates to:
  /// **'Loop GIF'**
  String get videoPresetLoop;

  /// No description provided for @videoTabAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get videoTabAnimation;

  /// No description provided for @videoTabQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get videoTabQuality;

  /// No description provided for @videoTabAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get videoTabAdvanced;

  /// No description provided for @videoAnimationType.
  ///
  /// In en, this message translates to:
  /// **'Animation Type'**
  String get videoAnimationType;

  /// No description provided for @videoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get videoDuration;

  /// No description provided for @videoFrames.
  ///
  /// In en, this message translates to:
  /// **'frames'**
  String get videoFrames;

  /// No description provided for @videoZoomFactor.
  ///
  /// In en, this message translates to:
  /// **'Zoom Factor'**
  String get videoZoomFactor;

  /// No description provided for @videoEasing.
  ///
  /// In en, this message translates to:
  /// **'Easing'**
  String get videoEasing;

  /// No description provided for @videoParameterSweep.
  ///
  /// In en, this message translates to:
  /// **'Parameter Sweep'**
  String get videoParameterSweep;

  /// No description provided for @videoSelectParameter.
  ///
  /// In en, this message translates to:
  /// **'Select Parameter'**
  String get videoSelectParameter;

  /// No description provided for @videoSweepStart.
  ///
  /// In en, this message translates to:
  /// **'Start Value'**
  String get videoSweepStart;

  /// No description provided for @videoSweepEnd.
  ///
  /// In en, this message translates to:
  /// **'End Value'**
  String get videoSweepEnd;

  /// No description provided for @videoPingPong.
  ///
  /// In en, this message translates to:
  /// **'Ping-Pong'**
  String get videoPingPong;

  /// No description provided for @videoPingPongHint.
  ///
  /// In en, this message translates to:
  /// **'Animate back to start value'**
  String get videoPingPongHint;

  /// No description provided for @videoFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get videoFormat;

  /// No description provided for @videoResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get videoResolution;

  /// No description provided for @videoFrameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame Rate'**
  String get videoFrameRate;

  /// No description provided for @videoQualityPreset.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get videoQualityPreset;

  /// No description provided for @videoLoop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get videoLoop;

  /// No description provided for @videoLoopHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat animation continuously'**
  String get videoLoopHint;

  /// No description provided for @videoWatermark.
  ///
  /// In en, this message translates to:
  /// **'Add Watermark'**
  String get videoWatermark;

  /// No description provided for @videoWatermarkHint.
  ///
  /// In en, this message translates to:
  /// **'Add \'Flutter Fractals\' branding'**
  String get videoWatermarkHint;

  /// No description provided for @videoEstimatedOutput.
  ///
  /// In en, this message translates to:
  /// **'Estimated Output'**
  String get videoEstimatedOutput;

  /// No description provided for @videoTotalFrames.
  ///
  /// In en, this message translates to:
  /// **'Total Frames'**
  String get videoTotalFrames;

  /// No description provided for @videoEstimatedSize.
  ///
  /// In en, this message translates to:
  /// **'Est. File Size'**
  String get videoEstimatedSize;

  /// No description provided for @videoExportNow.
  ///
  /// In en, this message translates to:
  /// **'Export Video'**
  String get videoExportNow;

  /// No description provided for @videoExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting video...'**
  String get videoExporting;

  /// No description provided for @videoExportProgress.
  ///
  /// In en, this message translates to:
  /// **'Rendering frame {current} of {total}'**
  String videoExportProgress(Object current, Object total);

  /// No description provided for @videoExportComplete.
  ///
  /// In en, this message translates to:
  /// **'Video exported successfully'**
  String get videoExportComplete;

  /// No description provided for @videoExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Video export failed: {error}'**
  String videoExportFailed(Object error);

  /// No description provided for @tooltipExportVideo.
  ///
  /// In en, this message translates to:
  /// **'Export Video'**
  String get tooltipExportVideo;

  /// No description provided for @tooltipOpenHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tooltipOpenHistory;

  /// No description provided for @autoExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Explore'**
  String get autoExploreTitle;

  /// No description provided for @autoExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically discover interesting areas'**
  String get autoExploreSubtitle;

  /// No description provided for @tooltipStartExplore.
  ///
  /// In en, this message translates to:
  /// **'Start auto-explore'**
  String get tooltipStartExplore;

  /// No description provided for @tooltipPauseExplore.
  ///
  /// In en, this message translates to:
  /// **'Pause auto-explore'**
  String get tooltipPauseExplore;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready to explore'**
  String get statusIdle;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusExploring.
  ///
  /// In en, this message translates to:
  /// **'Exploring...'**
  String get statusExploring;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedLabel;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyPosition.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String historyPosition(Object current, Object total);

  /// No description provided for @historyGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get historyGoBack;

  /// No description provided for @historyGoForward.
  ///
  /// In en, this message translates to:
  /// **'Go forward'**
  String get historyGoForward;

  /// No description provided for @historyTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTabHistory;

  /// No description provided for @historyTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get historyTabFavorites;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start exploring fractals to build your history'**
  String get historyEmptySubtitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite views to access them quickly'**
  String get favoritesEmptySubtitle;

  /// No description provided for @saveFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Favorite'**
  String get saveFavoriteTitle;

  /// No description provided for @favoritePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this view'**
  String get favoritePlaceholder;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @renameFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Favorite'**
  String get renameFavoriteTitle;

  /// No description provided for @deleteFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Favorite'**
  String get deleteFavoriteTitle;

  /// No description provided for @deleteFavoriteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deleteFavoriteMessage(Object name);

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @alreadyFavorite.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get alreadyFavorite;

  /// No description provided for @saveAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save as favorite'**
  String get saveAsFavorite;

  /// No description provided for @disable3dMessage.
  ///
  /// In en, this message translates to:
  /// **'3D fractals are disabled on this device.\n(Mandelbulb shader load stalls.)'**
  String get disable3dMessage;

  /// No description provided for @deepZoomCpuFallback.
  ///
  /// In en, this message translates to:
  /// **'Deep Zoom — tap for CPU precision'**
  String get deepZoomCpuFallback;

  /// No description provided for @rendererAuto.
  ///
  /// In en, this message translates to:
  /// **'Renderer preference: Auto'**
  String get rendererAuto;

  /// No description provided for @rendererCpu.
  ///
  /// In en, this message translates to:
  /// **'Renderer preference: CPU only'**
  String get rendererCpu;

  /// No description provided for @rendererGpu.
  ///
  /// In en, this message translates to:
  /// **'Renderer preference: GPU only (debug)'**
  String get rendererGpu;

  /// No description provided for @tooltipGpuDebug.
  ///
  /// In en, this message translates to:
  /// **'GPU debug report'**
  String get tooltipGpuDebug;

  /// No description provided for @tooltipRandomFractal.
  ///
  /// In en, this message translates to:
  /// **'Random Fractal'**
  String get tooltipRandomFractal;

  /// No description provided for @deletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get deletePresetTitle;

  /// No description provided for @deletePresetMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deletePresetMessage(Object name);

  /// No description provided for @presetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted'**
  String get presetDeleted;

  /// No description provided for @presetDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete preset'**
  String get presetDeleteFailed;

  /// No description provided for @renamePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Preset'**
  String get renamePresetTitle;

  /// No description provided for @renamePresetHint.
  ///
  /// In en, this message translates to:
  /// **'New preset name'**
  String get renamePresetHint;

  /// No description provided for @presetRenamed.
  ///
  /// In en, this message translates to:
  /// **'Preset renamed'**
  String get presetRenamed;

  /// No description provided for @presetRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t rename preset'**
  String get presetRenameFailed;

  /// No description provided for @tooltipDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get tooltipDeletePreset;

  /// No description provided for @tooltipRenamePreset.
  ///
  /// In en, this message translates to:
  /// **'Rename preset'**
  String get tooltipRenamePreset;

  /// No description provided for @quickActionSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get quickActionSaveLocation;

  /// No description provided for @quickActionOpenPresets.
  ///
  /// In en, this message translates to:
  /// **'Open presets'**
  String get quickActionOpenPresets;

  /// No description provided for @quickActionRandomFractal.
  ///
  /// In en, this message translates to:
  /// **'Random fractal'**
  String get quickActionRandomFractal;

  /// No description provided for @quickActionBackInHistory.
  ///
  /// In en, this message translates to:
  /// **'Back in view history'**
  String get quickActionBackInHistory;

  /// No description provided for @quickActionForwardInHistory.
  ///
  /// In en, this message translates to:
  /// **'Forward in view history'**
  String get quickActionForwardInHistory;

  /// No description provided for @quickActionRendererMode.
  ///
  /// In en, this message translates to:
  /// **'Renderer mode'**
  String get quickActionRendererMode;

  /// No description provided for @quickActionViewLogs.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get quickActionViewLogs;

  /// No description provided for @quickActionGpuDebugReport.
  ///
  /// In en, this message translates to:
  /// **'GPU debug report'**
  String get quickActionGpuDebugReport;

  /// No description provided for @debugReportOpenShaderLab.
  ///
  /// In en, this message translates to:
  /// **'Open Shader Lab'**
  String get debugReportOpenShaderLab;

  /// No description provided for @debugReportCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get debugReportCopyJson;

  /// No description provided for @rendererBackendTitle.
  ///
  /// In en, this message translates to:
  /// **'Renderer Backend'**
  String get rendererBackendTitle;

  /// No description provided for @rendererBackendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how fractals are rendered. Auto is recommended.'**
  String get rendererBackendSubtitle;

  /// No description provided for @rendererBackendAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get rendererBackendAuto;

  /// No description provided for @rendererBackendAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use GPU when healthy; fall back to CPU when needed.'**
  String get rendererBackendAutoSubtitle;

  /// No description provided for @rendererBackendCpuOnly.
  ///
  /// In en, this message translates to:
  /// **'CPU only (stable)'**
  String get rendererBackendCpuOnly;

  /// No description provided for @rendererBackendCpuOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use the stable CPU renderer.'**
  String get rendererBackendCpuOnlySubtitle;

  /// No description provided for @rendererBackendGpuOnly.
  ///
  /// In en, this message translates to:
  /// **'GPU only (debug)'**
  String get rendererBackendGpuOnly;

  /// No description provided for @rendererBackendGpuOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always try GPU rendering. May show black/invalid output on some devices.'**
  String get rendererBackendGpuOnlySubtitle;

  /// No description provided for @cpuFallbackTryGpu.
  ///
  /// In en, this message translates to:
  /// **'Try GPU'**
  String get cpuFallbackTryGpu;

  /// No description provided for @cpuFallbackReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get cpuFallbackReport;

  /// No description provided for @shaderErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get shaderErrorTryAgain;

  /// No description provided for @shaderErrorGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get shaderErrorGoBack;

  /// No description provided for @logViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Log ({filtered}/{total})'**
  String logViewerTitle(Object filtered, Object total);

  /// No description provided for @logExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Log ({count} entries)'**
  String logExportTitle(Object count);

  /// No description provided for @logCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get logCopyText;

  /// No description provided for @logShareText.
  ///
  /// In en, this message translates to:
  /// **'Share Text'**
  String get logShareText;

  /// No description provided for @logShareJson.
  ///
  /// In en, this message translates to:
  /// **'Share JSON'**
  String get logShareJson;

  /// No description provided for @logCopied.
  ///
  /// In en, this message translates to:
  /// **'Log copied to clipboard'**
  String get logCopied;

  /// No description provided for @logShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String logShareFailed(Object error);

  /// No description provided for @logFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter level'**
  String get logFilterTooltip;

  /// No description provided for @logFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get logFilterAll;

  /// No description provided for @logFilterDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug+'**
  String get logFilterDebug;

  /// No description provided for @logFilterInfo.
  ///
  /// In en, this message translates to:
  /// **'Info+'**
  String get logFilterInfo;

  /// No description provided for @logFilterWarn.
  ///
  /// In en, this message translates to:
  /// **'Warn+'**
  String get logFilterWarn;

  /// No description provided for @logFilterError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logFilterError;

  /// No description provided for @logNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No log entries'**
  String get logNoEntries;

  /// No description provided for @logTooltipExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get logTooltipExport;

  /// No description provided for @logTooltipClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get logTooltipClear;

  /// No description provided for @exportSimpleModeHint.
  ///
  /// In en, this message translates to:
  /// **'Simple mode — choose a quick preset, then tap Export or Share.'**
  String get exportSimpleModeHint;

  /// No description provided for @exportCustomizeModeHint.
  ///
  /// In en, this message translates to:
  /// **'Customization enabled — full export controls visible.'**
  String get exportCustomizeModeHint;

  /// No description provided for @exportButtonSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get exportButtonSimple;

  /// No description provided for @exportButtonCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get exportButtonCustomize;

  /// No description provided for @exportFormatPng.
  ///
  /// In en, this message translates to:
  /// **'PNG'**
  String get exportFormatPng;

  /// No description provided for @exportFormatJpg.
  ///
  /// In en, this message translates to:
  /// **'JPG'**
  String get exportFormatJpg;

  /// No description provided for @exportFormatWebp.
  ///
  /// In en, this message translates to:
  /// **'WebP'**
  String get exportFormatWebp;

  /// No description provided for @homeUnknownFractalType.
  ///
  /// In en, this message translates to:
  /// **'Unknown fractal type: {type}'**
  String homeUnknownFractalType(Object type);

  /// No description provided for @homeFractalCountBadge.
  ///
  /// In en, this message translates to:
  /// **'350+ fractals'**
  String get homeFractalCountBadge;

  /// No description provided for @catalogAllFractals.
  ///
  /// In en, this message translates to:
  /// **'All Fractals'**
  String get catalogAllFractals;

  /// No description provided for @catalogFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catalogFilterAll;

  /// No description provided for @catalogFilterSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get catalogFilterSortOrder;

  /// No description provided for @catalogSortByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get catalogSortByCategory;

  /// No description provided for @catalogSortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical A-Z'**
  String get catalogSortAlphabetical;

  /// No description provided for @catalogSortAlphabeticalShort.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get catalogSortAlphabeticalShort;

  /// No description provided for @catalogSwitchToList.
  ///
  /// In en, this message translates to:
  /// **'Switch to list view'**
  String get catalogSwitchToList;

  /// No description provided for @catalogSwitchToGrid.
  ///
  /// In en, this message translates to:
  /// **'Switch to grid view'**
  String get catalogSwitchToGrid;

  /// No description provided for @catalogListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get catalogListView;

  /// No description provided for @catalogGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get catalogGridView;

  /// No description provided for @catalogFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get catalogFeatured;

  /// No description provided for @catalogFilterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catalogFilterCategories;

  /// No description provided for @catalogResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get catalogResults;

  /// No description provided for @catalogCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catalogCategories;

  /// No description provided for @actionClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get actionClearFilters;

  /// No description provided for @historyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'HERE'**
  String get historyCurrentLocation;

  /// No description provided for @historySaveAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save as favorite'**
  String get historySaveAsFavorite;

  /// No description provided for @historyUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get historyUnnamed;

  /// No description provided for @historyRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get historyRename;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @navBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// No description provided for @navDockZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get navDockZoomOut;

  /// No description provided for @navDockZoomOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get navDockZoomOutTooltip;

  /// No description provided for @navDockReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get navDockReset;

  /// No description provided for @navDockResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get navDockResetTooltip;

  /// No description provided for @navDockZoomIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get navDockZoomIn;

  /// No description provided for @navDockZoomInTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get navDockZoomInTooltip;

  /// No description provided for @navDockRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get navDockRandom;

  /// No description provided for @navDockQuickNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick navigation. Current zoom {zoom}. Actions: zoom out, reset view, zoom in, random fractal.'**
  String navDockQuickNavLabel(Object zoom);

  /// No description provided for @tooltipMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tooltipMoreOptions;

  /// No description provided for @tooltipFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen view'**
  String get tooltipFullscreen;

  /// No description provided for @semanticSliderAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust from {min} to {max}'**
  String semanticSliderAdjust(Object min, Object max);

  /// No description provided for @semanticSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} section, {count} fractals'**
  String semanticSectionHeader(Object name, Object count);

  /// No description provided for @semanticFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Featured fractals carousel'**
  String get semanticFeaturedSection;

  /// No description provided for @semanticControlsSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'{title} controls section'**
  String semanticControlsSectionHeader(Object title);
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
