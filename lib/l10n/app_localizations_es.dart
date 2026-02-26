// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fractal Forge';

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
  String get batchExportTitle => 'Exportación por lote';

  @override
  String get batchExportAllPresets => 'Exportar todos los presets';

  @override
  String get batchExportPreparing => 'Preparando…';

  @override
  String get batchExportCancelling => 'Cancelando…';

  @override
  String get batchExportCancelled => 'Cancelado';

  @override
  String get batchExportDone => 'Listo';

  @override
  String get batchExportNoPresets => 'No hay presets para exportar.';

  @override
  String get batchExportSavedTo => 'Guardado en:';

  @override
  String get batchExportContactSheet => 'Hoja de contacto';

  @override
  String get batchExportCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

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
  String get sectionActions => 'Acciones';

  @override
  String get resetView => 'Restablecer vista';

  @override
  String get resetParams => 'Restablecer parámetros';

  @override
  String get randomize => 'Aleatorizar';

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportQuickPresets => 'Presets Rápidos';

  @override
  String get exportPresetSocial => 'Social';

  @override
  String get exportPresetHighQuality => 'Alta Calidad';

  @override
  String get exportPresetWeb => 'Web';

  @override
  String get exportPresetTransparent => 'Transparente';

  @override
  String get exportFormat => 'Formato';

  @override
  String get exportFormatHintPng =>
      'Calidad sin pérdida, soporta transparencia. Ideal para edición.';

  @override
  String get exportFormatHintJpg =>
      'Archivo más pequeño, excelente para compartir. Sin transparencia.';

  @override
  String get exportFormatHintWebp =>
      'Formato moderno con excelente compresión. Amplio soporte.';

  @override
  String get exportResolution => 'Resolución';

  @override
  String get exportWidth => 'Ancho';

  @override
  String get exportHeight => 'Alto';

  @override
  String get exportQuality => 'Calidad';

  @override
  String get exportAdvancedOptions => 'Opciones Avanzadas';

  @override
  String get exportTransparentBg => 'Fondo Transparente';

  @override
  String get exportTransparentBgHint =>
      'Eliminar el fondo para usar como superposición';

  @override
  String get exportEmbedMetadata => 'Incluir Metadatos';

  @override
  String get exportEmbedMetadataHint =>
      'Incluir los parámetros del fractal en el archivo';

  @override
  String get exportScreenResolution => 'Tamaño de pantalla';

  @override
  String get exportSummary => 'Resumen de Exportación';

  @override
  String get exportNow => 'Exportar Ahora';

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
  String get modulePhoenix => 'Fénix';

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
  String get paramPhoenixCReal => 'Fénix C (Real)';

  @override
  String get paramPhoenixCImag => 'Fénix C (Imag)';

  @override
  String get paramPhoenixP => 'Fénix P (Memoria)';

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
  String get arSafetyWarningTitle => 'Advertencia de seguridad AR';

  @override
  String get arSafetyWarningBody =>
      '• Se recomienda supervisión parental cuando niñas y niños usan AR.\n• Mantente atento a tu entorno y guarda distancia de objetos.\n• No se requiere casco ni dispositivo ponible.';

  @override
  String get arSafetyContinue => 'Continuar';

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
  String get colorPhoenix => 'Fénix';

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
  String get tooltipWallpaper => 'Establecer como Fondo';

  @override
  String get wallpaperTitle => 'Fondo de pantalla';

  @override
  String get wallpaperAndroidNote =>
      'Exporta a la resolución nativa del dispositivo y lo establece como fondo.';

  @override
  String get wallpaperIosNote =>
      'iOS no permite que las apps establezcan el fondo directamente. Guardaremos la imagen en Fotos para que la configures desde ahí.';

  @override
  String get wallpaperTarget => 'Destino';

  @override
  String get wallpaperTargetHome => 'Inicio';

  @override
  String get wallpaperTargetLock => 'Bloqueo';

  @override
  String get wallpaperTargetBoth => 'Ambos';

  @override
  String get wallpaperPresets => 'Presets';

  @override
  String get wallpaperPresetPlain => 'Normal';

  @override
  String get wallpaperPresetHome => 'Optimizado (Inicio)';

  @override
  String get wallpaperPresetLock => 'Optimizado (Bloqueo)';

  @override
  String get wallpaperSaveCopy => 'Guardar una copia';

  @override
  String get wallpaperSaveCopySubtitle =>
      'También exporta y abre el menú de compartir.';

  @override
  String get wallpaperApply => 'Aplicar';

  @override
  String get wallpaperApplied => 'Fondo listo';

  @override
  String get wallpaperFailed => 'No se pudo aplicar el fondo';

  @override
  String wallpaperFailedWithError(Object error) {
    return 'No se pudo aplicar el fondo: $error';
  }

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

  @override
  String get arStyleNeon => 'Neón';

  @override
  String get arStyleSoft => 'Suave';

  @override
  String get arStyleMono => 'Mono';

  @override
  String get arStyleTitle => 'Estilo';

  @override
  String get arShowGrid => 'Cuadrícula';

  @override
  String get arShowOutline => 'Contorno';

  @override
  String get arCenter => 'Centrar';

  @override
  String get arMoreOptions => 'Más';

  @override
  String get tooltipExpand => 'Expandir';

  @override
  String get tooltipCollapse => 'Contraer';

  @override
  String get errorOverlayNotReady => 'Superposición no lista';

  @override
  String get errorCameraNotReady => 'Cámara no lista';

  @override
  String get shaderLoadFailed => 'Error al cargar el shader';

  @override
  String get contextMenuResetView => 'Restablecer vista';

  @override
  String get contextMenuOpenControls => 'Abrir controles';

  @override
  String get contextMenuOpenPresets => 'Abrir presets';

  @override
  String get contextMenuRandomize => 'Aleatorizar';

  @override
  String get contextMenuExport => 'Exportar';

  @override
  String get gestureDoubleTapReset => 'Vista restablecida';

  @override
  String get accessibilityTitle => 'Accesibilidad';

  @override
  String get accessibilityHighContrast => 'Alto Contraste';

  @override
  String get accessibilityHighContrastHint =>
      'Usar colores brillantes con máximo contraste';

  @override
  String get accessibilityReducedMotion => 'Reducir Movimiento';

  @override
  String get accessibilityReducedMotionHint =>
      'Minimizar animaciones y transiciones';

  @override
  String get accessibilityLargeTargets => 'Objetivos Táctiles Grandes';

  @override
  String get accessibilityLargeTargetsHint =>
      'Aumentar el tamaño de los elementos interactivos';

  @override
  String get accessibilityScreenReaderActive =>
      'El lector de pantalla está activo';

  @override
  String get soundEffectsTitle => 'Efectos de Sonido';

  @override
  String get soundEffectsEnabled => 'Sonidos de Interfaz';

  @override
  String get soundEffectsEnabledHint =>
      'Reproducir sonidos sutiles para toques y transiciones';

  @override
  String get soundEffectsVolume => 'Volumen';

  @override
  String get semanticFractalViewer =>
      'Visor de fractales interactivo. Pellizca para acercar, arrastra para desplazar.';

  @override
  String semanticFractalCard(Object name, Object dimension) {
    return 'Fractal $name, $dimension. Toca dos veces para abrir.';
  }

  @override
  String semanticSlider(Object label, Object value, Object min, Object max) {
    return 'Control deslizante $label. Valor actual: $value. Mínimo: $min, Máximo: $max';
  }

  @override
  String get semanticNavExplore =>
      'Pestaña Explorar. Navegar por el catálogo de fractales.';

  @override
  String get semanticNavAr =>
      'Pestaña AR. Ver fractales en realidad aumentada.';

  @override
  String get semanticBackButton => 'Volver a la pantalla anterior';

  @override
  String get semanticCloseButton => 'Cerrar este diálogo';

  @override
  String get semanticSearchField => 'Buscar fractales por nombre';

  @override
  String get semanticExportButton => 'Exportar el fractal actual como imagen';

  @override
  String get semanticControlsButton =>
      'Abrir controles de parámetros del fractal';

  @override
  String get semanticPresetsButton => 'Abrir presets guardados';

  @override
  String get semanticRandomizeButton =>
      'Aleatorizar todos los parámetros del fractal';

  @override
  String get semanticResetViewButton =>
      'Restablecer la vista a la posición predeterminada';

  @override
  String get semanticResetParamsButton =>
      'Restablecer todos los parámetros a sus valores predeterminados';

  @override
  String semanticZoomLevel(Object percent) {
    return 'Nivel de zoom: $percent por ciento';
  }

  @override
  String get semanticLoadingShaders =>
      'Cargando shaders de fractales, por favor espere';

  @override
  String semanticExportProgress(Object percent) {
    return 'Exportando imagen, $percent por ciento completado';
  }

  @override
  String semanticPresetItem(Object name) {
    return 'Preset $name. Toca dos veces para aplicar.';
  }

  @override
  String semanticToggleOn(Object label) {
    return '$label, actualmente encendido. Toca dos veces para apagar.';
  }

  @override
  String semanticToggleOff(Object label) {
    return '$label, actualmente apagado. Toca dos veces para encender.';
  }

  @override
  String announceFractalLoaded(Object name) {
    return 'Fractal $name cargado';
  }

  @override
  String announcePresetApplied(Object name) {
    return 'Preset $name aplicado';
  }

  @override
  String get announceExportComplete => 'Exportación completada';

  @override
  String get announceViewReset =>
      'Vista restablecida a los valores predeterminados';

  @override
  String get announceParamsRandomized => 'Parámetros aleatorizados';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Flutter Fractales';

  @override
  String get onboardingWelcomeDescription =>
      'Explora la belleza infinita de los fractales matemáticos con renderizado en tiempo real acelerado por GPU.';

  @override
  String get onboardingFractalTypesTitle => 'Descubre Tipos de Fractales';

  @override
  String get onboardingFractalTypesDescription =>
      'Desde fractales 2D clásicos hasta el impresionante Mandelbulb 3D, explora una variedad de arte matemático.';

  @override
  String get onboardingGesturesTitle => 'Controles Intuitivos';

  @override
  String get onboardingGesturesDescription =>
      'Navega por los fractales con gestos simples y naturales.';

  @override
  String get onboardingGesturePan => 'Desplazar';

  @override
  String get onboardingGesturePanDesc => 'Arrastra con un dedo para moverte';

  @override
  String get onboardingGestureZoom => 'Acercar';

  @override
  String get onboardingGestureZoomDesc => 'Pellizca para acercar y alejar';

  @override
  String get onboardingGestureRotate => 'Rotar';

  @override
  String get onboardingGestureRotateDesc =>
      'Rota con dos dedos para fractales 3D';

  @override
  String get onboardingGestureDoubleTap => 'Doble Toque';

  @override
  String get onboardingGestureDoubleTapDesc =>
      'Restablecimiento rápido a la vista predeterminada';

  @override
  String get onboardingFeaturesTitle => 'Funciones Poderosas';

  @override
  String get onboardingFeaturesDescription =>
      'Crea, personaliza y comparte tus creaciones fractales.';

  @override
  String get onboardingFeaturePresets => 'Presets';

  @override
  String get onboardingFeaturePresetsDesc =>
      'Guarda y carga tus configuraciones favoritas';

  @override
  String get onboardingFeatureExport => 'Exportar';

  @override
  String get onboardingFeatureExportDesc =>
      'Guarda imágenes de alta calidad en múltiples formatos';

  @override
  String get onboardingFeatureAr => 'Modo AR';

  @override
  String get onboardingFeatureArDesc =>
      'Superpone fractales en la vista de tu cámara';

  @override
  String get shareTitle => 'Compartir Fractal';

  @override
  String shareSubtitle(Object fractalName) {
    return '¡Mira este fractal $fractalName que creé!';
  }

  @override
  String get tooltipShare => 'Compartir';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get linkCopied => 'Enlace copiado al portapapeles';

  @override
  String shareMessage(Object fractalName, Object link) {
    return '¡Mira este fractal $fractalName! $link';
  }

  @override
  String shareSubject(Object fractalName) {
    return 'Fractal $fractalName - Flutter Fractals';
  }

  @override
  String get videoExportTitle => 'Exportar Video';

  @override
  String get videoPresetQuickGif => 'GIF Rápido';

  @override
  String get videoPresetSocial => 'Redes Sociales';

  @override
  String get videoPresetHighQuality => 'Alta Calidad';

  @override
  String get videoPresetLoop => 'GIF en Bucle';

  @override
  String get videoTabAnimation => 'Animación';

  @override
  String get videoTabQuality => 'Calidad';

  @override
  String get videoTabAdvanced => 'Avanzado';

  @override
  String get videoAnimationType => 'Tipo de Animación';

  @override
  String get videoDuration => 'Duración';

  @override
  String get videoFrames => 'cuadros';

  @override
  String get videoZoomFactor => 'Factor de Zoom';

  @override
  String get videoEasing => 'Suavizado';

  @override
  String get videoParameterSweep => 'Barrido de Parámetro';

  @override
  String get videoSelectParameter => 'Seleccionar Parámetro';

  @override
  String get videoSweepStart => 'Valor Inicial';

  @override
  String get videoSweepEnd => 'Valor Final';

  @override
  String get videoPingPong => 'Ping-Pong';

  @override
  String get videoPingPongHint => 'Animar de vuelta al valor inicial';

  @override
  String get videoFormat => 'Formato';

  @override
  String get videoResolution => 'Resolución';

  @override
  String get videoFrameRate => 'Cuadros por Segundo';

  @override
  String get videoQualityPreset => 'Calidad';

  @override
  String get videoLoop => 'Bucle';

  @override
  String get videoLoopHint => 'Repetir animación continuamente';

  @override
  String get videoWatermark => 'Agregar Marca de Agua';

  @override
  String get videoWatermarkHint => 'Agregar marca \'Flutter Fractals\'';

  @override
  String get videoEstimatedOutput => 'Salida Estimada';

  @override
  String get videoTotalFrames => 'Total de Cuadros';

  @override
  String get videoEstimatedSize => 'Tamaño Est. del Archivo';

  @override
  String get videoExportNow => 'Exportar Video';

  @override
  String get videoExporting => 'Exportando video...';

  @override
  String videoExportProgress(Object current, Object total) {
    return 'Renderizando cuadro $current de $total';
  }

  @override
  String get videoExportComplete => 'Video exportado exitosamente';

  @override
  String videoExportFailed(Object error) {
    return 'Exportación de video fallida: $error';
  }

  @override
  String get tooltipExportVideo => 'Exportar Video';

  @override
  String get tooltipOpenHistory => 'Historial';

  @override
  String get autoExploreTitle => 'Auto-Explorar';

  @override
  String get autoExploreSubtitle =>
      'Descubre automáticamente áreas interesantes';

  @override
  String get tooltipStartExplore => 'Iniciar auto-exploración';

  @override
  String get tooltipPauseExplore => 'Pausar auto-exploración';

  @override
  String get statusIdle => 'Listo para explorar';

  @override
  String get statusPaused => 'Pausado';

  @override
  String get statusExploring => 'Explorando...';

  @override
  String get speedLabel => 'Velocidad';

  @override
  String get speedSlow => 'Lento';

  @override
  String get speedFast => 'Rápido';

  @override
  String get actionPlay => 'Reproducir';

  @override
  String get actionPause => 'Pausar';

  @override
  String get actionStop => 'Detener';

  @override
  String get historyTitle => 'Historial';

  @override
  String historyPosition(Object current, Object total) {
    return '$current de $total';
  }

  @override
  String get historyGoBack => 'Atrás';

  @override
  String get historyGoForward => 'Adelante';

  @override
  String get historyTabHistory => 'Historial';

  @override
  String get historyTabFavorites => 'Favoritos';

  @override
  String get historyEmptyTitle => 'Sin historial';

  @override
  String get historyEmptySubtitle =>
      'Explora fractales para construir tu historial';

  @override
  String get favoritesEmptyTitle => 'Sin favoritos';

  @override
  String get favoritesEmptySubtitle =>
      'Guarda tus vistas favoritas para acceder rápidamente';

  @override
  String get saveFavoriteTitle => 'Guardar Favorito';

  @override
  String get favoritePlaceholder => 'Nombre para esta vista';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get renameFavoriteTitle => 'Renombrar Favorito';

  @override
  String get deleteFavoriteTitle => 'Eliminar Favorito';

  @override
  String deleteFavoriteMessage(Object name) {
    return '¿Eliminar \"$name\"? Esto no se puede deshacer.';
  }

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get alreadyFavorite => 'Ya guardado';

  @override
  String get saveAsFavorite => 'Guardar como favorito';

  @override
  String get disable3dMessage =>
      'Los fractales 3D están desactivados en este dispositivo.\n(La carga del shader Mandelbulb se detiene.)';

  @override
  String get deepZoomCpuFallback => 'Zoom profundo — toca para precisión CPU';

  @override
  String get rendererAuto => 'Preferencia de renderizado: Automático';

  @override
  String get rendererCpu => 'Preferencia de renderizado: Solo CPU';

  @override
  String get rendererGpu => 'Preferencia de renderizado: Solo GPU (depuración)';

  @override
  String get tooltipGpuDebug => 'Informe de depuración GPU';

  @override
  String get tooltipRandomFractal => 'Fractal aleatorio';

  @override
  String get deletePresetTitle => 'Eliminar preset';

  @override
  String deletePresetMessage(Object name) {
    return '¿Eliminar \"$name\"? Esto no se puede deshacer.';
  }

  @override
  String get presetDeleted => 'Preset eliminado';

  @override
  String get presetDeleteFailed => 'No se pudo eliminar el preset';

  @override
  String get renamePresetTitle => 'Renombrar preset';

  @override
  String get renamePresetHint => 'Nuevo nombre del preset';

  @override
  String get presetRenamed => 'Preset renombrado';

  @override
  String get presetRenameFailed => 'No se pudo renombrar el preset';

  @override
  String get tooltipDeletePreset => 'Eliminar preset';

  @override
  String get tooltipRenamePreset => 'Renombrar preset';

  @override
  String get quickActionSaveLocation => 'Guardar ubicación';

  @override
  String get quickActionOpenPresets => 'Abrir presets';

  @override
  String get quickActionRandomFractal => 'Fractal aleatorio';

  @override
  String get quickActionBackInHistory => 'Atrás en el historial';

  @override
  String get quickActionForwardInHistory => 'Adelante en el historial';

  @override
  String get quickActionRendererMode => 'Modo de renderizado';

  @override
  String get quickActionViewLogs => 'Ver registros';

  @override
  String get quickActionGpuDebugReport => 'Informe de depuración GPU';

  @override
  String get debugReportOpenShaderLab => 'Abrir Shader Lab';

  @override
  String get debugReportCopyJson => 'Copiar JSON';

  @override
  String get rendererBackendTitle => 'Motor de renderizado';

  @override
  String get rendererBackendSubtitle =>
      'Elige cómo se renderizan los fractales. Se recomienda Automático.';

  @override
  String get rendererBackendAuto => 'Automático';

  @override
  String get rendererBackendAutoSubtitle =>
      'Usa GPU cuando está sana; cambia a CPU cuando es necesario.';

  @override
  String get rendererBackendCpuOnly => 'Solo CPU (estable)';

  @override
  String get rendererBackendCpuOnlySubtitle =>
      'Usa siempre el renderizador CPU estable.';

  @override
  String get rendererBackendGpuOnly => 'Solo GPU (depuración)';

  @override
  String get rendererBackendGpuOnlySubtitle =>
      'Siempre intenta el renderizado GPU. Puede mostrar salida negra o inválida en algunos dispositivos.';

  @override
  String get cpuFallbackTryGpu => 'Probar GPU';

  @override
  String get cpuFallbackReport => 'Reportar';

  @override
  String get shaderErrorTryAgain => 'Intentar de nuevo';

  @override
  String get shaderErrorGoBack => 'Volver';
}
