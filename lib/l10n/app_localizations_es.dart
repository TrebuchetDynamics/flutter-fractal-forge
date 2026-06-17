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
  String get tabFavorites => 'Favoritos';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

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
  String get catalogClearFilters => 'Limpiar todo';

  @override
  String catalogResultsCount(int count) {
    return '$count resultados';
  }

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
  String get sectionParameters => 'Parámetros';

  @override
  String get sectionGlow => 'Brillo';

  @override
  String get glowEnable => 'Activar';

  @override
  String get glowStrength => 'Intensidad';

  @override
  String get glowSoftness => 'Suavidad';

  @override
  String get resetView => 'Restablecer vista';

  @override
  String get resetParams => 'Restablecer parámetros';

  @override
  String get randomize => 'Aleatorizar';

  @override
  String get kaleidoscopeEnable => 'Activar';

  @override
  String get kaleidoscopeSectors => 'Sectores';

  @override
  String get kaleidoscopeRotation => 'Rotar';

  @override
  String get kaleidoscopeMirror => 'Espejo';

  @override
  String get kaleidoscopeMirrorAlternate => 'Alternado';

  @override
  String get kaleidoscopeMirrorDouble => 'Doble';

  @override
  String get kaleidoscopeMirrorTriple => 'Triple';

  @override
  String get kaleidoscopeMirrorNone => 'Sin';

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
      'WebP aún no se codifica; la exportación usa PNG de respaldo.';

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
  String get dimensionKaleidoscope => 'Kaleidoscopio';

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
  String get fractalSection2d => '2D';

  @override
  String get fractalSection3d => '3D';

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
      'También guarda una copia en tu galería.';

  @override
  String get wallpaperApply => 'Aplicar';

  @override
  String get wallpaperApplied => 'Fondo listo';

  @override
  String get wallpaperSavedToPhotos => 'Guardado en Fotos';

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
  String get exportActionSaveImage => 'Guardar imagen';

  @override
  String get exportActionSaveAndShare => 'Guardar y compartir';

  @override
  String get exportSaveLocationHint =>
      'Se guarda en Imágenes/FractalForge. No requiere permiso de almacenamiento.';

  @override
  String get exportFormatFallbackPng => 'PNG de respaldo';

  @override
  String get exportSavedShareFailed =>
      'Exportación guardada. No se abrió compartir; intenta compartir la imagen guardada desde Fotos.';

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
  String get semanticSplashScreen =>
      'Pantalla de presentación de Fractal Forge';

  @override
  String get splashTagline => 'Explora patrones matemáticos infinitos';

  @override
  String semanticOnboardingProgress(Object step, Object total) {
    return 'Progreso de incorporación, paso $step de $total';
  }

  @override
  String get semanticSkipOnboarding => 'Omitir incorporación';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Fractal Forge';

  @override
  String get onboardingWelcomeDescription =>
      'Explora belleza matemática infinita a través de más de 350 fractales interactivos con renderizado acelerado por GPU, desde conjuntos de Mandelbrot hasta atractores extraños.';

  @override
  String get onboardingWelcomeHighlight1 =>
      'Desplaza y pellizca para navegar con zoom profundo y precisión infinita';

  @override
  String get onboardingWelcomeHighlight2 =>
      'Descubre estructura en Mandelbrot, Julia, Newton y más de 350 tipos de fractales';

  @override
  String get onboardingWelcomeHighlight3 =>
      'Renderizado acelerado por GPU para una exploración suave en tiempo real';

  @override
  String get onboardingCreateTitle => 'Crea, exporta y comparte';

  @override
  String get onboardingCreateDescription =>
      'Ajusta parámetros en tiempo real y exporta impresionantes imágenes de alta resolución para compartir.';

  @override
  String get onboardingCreateHighlight1 =>
      'Controles de parámetros en tiempo real con más de 60 esquemas de color';

  @override
  String get onboardingCreateHighlight2 =>
      'Exporta a PNG y comparte, perfecto para arte, presentaciones y estudio';

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
  String get tooltipExitFullscreen => 'Salir de pantalla completa';

  @override
  String get announceEnteredFullscreen => 'Pantalla completa activada';

  @override
  String get announceExitedFullscreen => 'Pantalla completa desactivada';

  @override
  String get announceMinimapShown => 'Minimapa mostrado';

  @override
  String get announceMinimapHidden => 'Minimapa oculto';

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

  @override
  String logViewerTitle(Object filtered, Object total) {
    return 'Registro ($filtered/$total)';
  }

  @override
  String logExportTitle(Object count) {
    return 'Exportar registro ($count entradas)';
  }

  @override
  String get logCopyText => 'Copiar texto';

  @override
  String get logShareText => 'Compartir texto';

  @override
  String get logShareJson => 'Compartir JSON';

  @override
  String get logCopied => 'Registro copiado al portapapeles';

  @override
  String logShareFailed(Object error) {
    return 'Error al compartir: $error';
  }

  @override
  String get logFilterTooltip => 'Filtrar nivel';

  @override
  String get logFilterAll => 'Todos';

  @override
  String get logFilterDebug => 'Debug+';

  @override
  String get logFilterInfo => 'Info+';

  @override
  String get logFilterWarn => 'Advertencia+';

  @override
  String get logFilterError => 'Error';

  @override
  String get logNoEntries => 'Sin entradas de registro';

  @override
  String get logTooltipExport => 'Exportar';

  @override
  String get logTooltipClear => 'Limpiar';

  @override
  String get exportSimpleModeHint =>
      'Modo simple — elige un preset rápido, luego toca Exportar o Compartir.';

  @override
  String get exportCustomizeModeHint =>
      'Personalización activada — todos los controles de exportación visibles.';

  @override
  String get exportButtonSimple => 'Simple';

  @override
  String get exportButtonCustomize => 'Personalizar';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportFormatJpg => 'JPG';

  @override
  String get exportFormatWebp => 'WebP';

  @override
  String homeUnknownFractalType(Object type) {
    return 'Tipo de fractal desconocido: $type';
  }

  @override
  String get homeFractalCountBadge => '350+ fractales';

  @override
  String get catalogAllFractals => 'Todos los fractales';

  @override
  String get catalogFilterAll => 'Todos';

  @override
  String get catalogFilterSortOrder => 'Orden';

  @override
  String get catalogSortByCategory => 'Por categoría';

  @override
  String get catalogSortAlphabetical => 'Alfabético A-Z';

  @override
  String get catalogSortAlphabeticalShort => 'A-Z';

  @override
  String get catalogSwitchToList => 'Cambiar a vista de lista';

  @override
  String get catalogSwitchToGrid => 'Cambiar a vista de cuadrícula';

  @override
  String get catalogListView => 'Vista de lista';

  @override
  String get catalogGridView => 'Vista de cuadrícula';

  @override
  String get catalogFeatured => 'DESTACADOS';

  @override
  String get catalogFilterCategories => 'Categorías';

  @override
  String get catalogResults => 'Resultados';

  @override
  String get catalogCategories => 'Categorías';

  @override
  String get actionClearFilters => 'Limpiar filtros';

  @override
  String get historyCurrentLocation => 'AQUÍ';

  @override
  String get historySaveAsFavorite => 'Guardar como favorito';

  @override
  String get historyUnnamed => 'Sin nombre';

  @override
  String get historyRename => 'Renombrar';

  @override
  String get historyDelete => 'Eliminar';

  @override
  String get navBack => 'Atrás';

  @override
  String get navDockZoomOut => 'Alejar';

  @override
  String get navDockZoomOutTooltip => 'Alejar';

  @override
  String get navDockReset => 'Inicio';

  @override
  String get navDockResetTooltip => 'Restablecer vista';

  @override
  String get navDockZoomIn => 'Acercar';

  @override
  String get navDockZoomInTooltip => 'Acercar';

  @override
  String get navDockRandom => 'Aleatorio';

  @override
  String navDockQuickNavLabel(Object zoom) {
    return 'Navegación rápida. Zoom actual $zoom. Acciones: alejar, restablecer vista, acercar, fractal aleatorio.';
  }

  @override
  String get tooltipMoreOptions => 'Más opciones';

  @override
  String get tooltipFullscreen => 'Pantalla completa';

  @override
  String semanticSliderAdjust(Object min, Object max) {
    return 'Ajustar de $min a $max';
  }

  @override
  String semanticSectionHeader(Object name, Object count) {
    return 'Sección $name, $count fractales';
  }

  @override
  String get semanticFeaturedSection => 'Carrusel de fractales destacados';

  @override
  String semanticControlsSectionHeader(Object title) {
    return 'Sección de controles $title';
  }
}
