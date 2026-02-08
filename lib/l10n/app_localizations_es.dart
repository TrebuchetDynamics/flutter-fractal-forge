// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fractales Flutter';

  @override
  String get tabExplore => 'Explorar';

  @override
  String get tabAr => 'AR';

  @override
  String get catalogTitle => 'Catálogo de fractales';

  @override
  String get catalogSearchHint => 'Buscar fractales';

  @override
  String get catalogSearchEmpty =>
      'No hay fractales que coincidan con tu búsqueda.';

  @override
  String get actionClearSearch => 'Borrar búsqueda';

  @override
  String get viewerTitle => 'Visor de fractales';

  @override
  String get controlsTitle => 'Controles';

  @override
  String get presetsTitle => 'Presets';

  @override
  String get builtInPresets => 'Incluidos';

  @override
  String get userPresets => 'Tus presets';

  @override
  String get loadingPresets => 'Cargando presets…';

  @override
  String get noUserPresets => 'Aún no tienes presets guardados.';

  @override
  String get presetsLoadFailed => 'No se pudieron cargar los presets.';

  @override
  String get savePreset => 'Guardar preset';

  @override
  String get presetNameHint => 'Nombre del preset';

  @override
  String get presetSaved => 'Preset guardado';

  @override
  String get presetNameRequired => 'Escribe un nombre para el preset.';

  @override
  String presetSaveFailed(Object error) {
    return 'No se pudo guardar el preset: $error';
  }

  @override
  String get resetView => 'Restablecer vista';

  @override
  String get resetParams => 'Restablecer parámetros';

  @override
  String get randomize => 'Aleatorizar';

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportPng => 'PNG';

  @override
  String get exportTransparentPng => 'PNG transparente';

  @override
  String get exportArScreenshot => 'Captura AR horneada';

  @override
  String get exportArVideo => 'Video AR horneado';

  @override
  String get exportArVideoStub =>
      'La exportación de video AR está en andamiaje pero aún no se hornea.';

  @override
  String exportFailed(Object error) {
    return 'Error al exportar: $error';
  }

  @override
  String get exportSaved => 'Exportación guardada';

  @override
  String get exporting => 'Exportando...';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionOpenSettings => 'Abrir ajustes';

  @override
  String get share => 'Compartir';

  @override
  String get loadingShaders => 'Cargando shaders...';

  @override
  String get moduleMandelbrot => 'Mandelbrot';

  @override
  String get moduleJulia => 'Julia';

  @override
  String get moduleBurningShip => 'Barco ardiente';

  @override
  String get moduleMandelbulb => 'Mandelbulb';

  @override
  String get dimension2d => '2D';

  @override
  String get dimension3d => '3D';

  @override
  String get paramIterations => 'Iteraciones';

  @override
  String get paramSteps => 'Pasos';

  @override
  String get paramBailout => 'Escape';

  @override
  String get paramPower => 'Potencia';

  @override
  String get paramColorScheme => 'Esquema de color';

  @override
  String get paramFractalType => 'Tipo de fractal';

  @override
  String get paramJuliaCReal => 'Julia C (Real)';

  @override
  String get paramJuliaCImag => 'Julia C (Imag)';

  @override
  String get paramOpacity => 'Opacidad';

  @override
  String get paramLockOverlay => 'Bloquear superposición';

  @override
  String get paramTransparentBg => 'Fondo transparente';

  @override
  String get arQualityPreset => 'Calidad AR';

  @override
  String get arQualityLow => 'Baja';

  @override
  String get arQualityMedium => 'Media';

  @override
  String get arQualityHigh => 'Alta';

  @override
  String get arTitle => 'Superposición AR';

  @override
  String get arSelectFractal => 'Fractal';

  @override
  String get fractalSection2d => '2D';

  @override
  String get fractalSection3d => '3D';

  @override
  String get arPermissionRequest =>
      'Se requiere permiso de cámara para el modo AR.';

  @override
  String get arPermissionDenied => 'Permiso de cámara denegado.';

  @override
  String get arCameraUnavailable => 'No hay cámara disponible.';

  @override
  String get arCameraUnavailableHelp =>
      'Asegúrate de que otra app no esté usando la cámara e inténtalo de nuevo.';

  @override
  String get arOverlayOnlyExport => 'PNG solo superposición';

  @override
  String get arBakedScreenshotExport => 'Cámara + superposición horneadas';

  @override
  String get arVideoExport => 'Grabar video AR';

  @override
  String get arVideoExportFailed => 'La exportación de video AR falló.';

  @override
  String get arVideoFallbackNotice =>
      'FFmpeg no está disponible o falló. Se exportó un GIF de baja fps (archivo grande, sin audio).';

  @override
  String get arDuration5 => '5s';

  @override
  String get arDuration10 => '10s';

  @override
  String get arDuration15 => '15s';

  @override
  String get colorFire => 'Fuego';

  @override
  String get colorOcean => 'Océano';

  @override
  String get colorPsychedelic => 'Psicodélico';

  @override
  String get colorGrayscale => 'Escala de grises';

  @override
  String get fractalTypeMandelbulb => 'Mandelbulb';

  @override
  String get fractalTypeMandelbox => 'Mandelbox';

  @override
  String get fractalTypeJulia => 'Julia';

  @override
  String get fractalTypeSierpinski => 'Sierpinski';

  @override
  String get tooltipOpenControls => 'Controles';

  @override
  String get tooltipOpenPresets => 'Presets';

  @override
  String get tooltipExport => 'Exportar';

  @override
  String get presetDefault => 'Predeterminado';

  @override
  String get presetClassic => 'Clásico';

  @override
  String get presetSoftGlow => 'Brillo suave';

  @override
  String get presetPsychedelic => 'Psicodélico';

  @override
  String get presetDeepBloom => 'Floración profunda';
}
