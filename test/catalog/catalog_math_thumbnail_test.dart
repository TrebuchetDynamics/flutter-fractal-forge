import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('thumbnail palette matches the named default, not an ID-derived color',
      () {
    final module = ModuleRegistry().byId('f0166_chebyshev_julia');
    expect(CatalogThumbnailCache.paletteIndexForModule(module),
        (module.defaultPreset.params['colorScheme'] as num).toInt());
  });

  test('changed mathematical defaults invalidate thumbnails with the same ID',
      () {
    final module = ModuleRegistry().byId('f0166_chebyshev_julia');
    final legacy = _withPreset(
        module,
        module.defaultPreset.copyWith(params: {
          ...module.defaultPreset.params,
          'juliaCReal': 2.0,
        }));
    final corrected = _withPreset(
        module,
        module.defaultPreset.copyWith(params: {
          ...module.defaultPreset.params,
          'juliaCReal': -2.0,
        }));
    expect(
      CatalogThumbnailCache.renderSignatureForModule(
          'core.${module.id}', legacy),
      isNot(CatalogThumbnailCache.renderSignatureForModule(
          'core.${module.id}', corrected)),
    );
  });

  test('changed default framing invalidates thumbnails', () {
    final module = ModuleRegistry().byId('mandelbrot');
    final changed = _withPreset(
        module,
        module.defaultPreset.copyWith(
          view: module.defaultPreset.view.copyWith(zoom: 2),
        ));
    expect(
      CatalogThumbnailCache.renderSignatureForModule('core.mandelbrot', module),
      isNot(CatalogThumbnailCache.renderSignatureForModule(
          'core.mandelbrot', changed)),
    );
  });

  test('parameter map order does not change the thumbnail recipe', () {
    final module = ModuleRegistry().byId('f0166_chebyshev_julia');
    final reordered = _withPreset(
        module,
        module.defaultPreset.copyWith(params: {
          for (final key in module.defaultPreset.params.keys.toList().reversed)
            key: module.defaultPreset.params[key]!,
        }));
    expect(
      CatalogThumbnailCache.renderSignatureForModule(
          'core.${module.id}', module),
      CatalogThumbnailCache.renderSignatureForModule(
          'core.${module.id}', reordered),
    );
  });
}

FractalModule _withPreset(FractalModule module, FractalPreset preset) =>
    FractalModule(
      id: module.id,
      displayName: module.displayName,
      dimension: module.dimension,
      animationCapability: module.animationCapability,
      shaderAsset: module.shaderAsset,
      parameters: module.parameters,
      defaultPreset: preset,
      builtInPresets: module.builtInPresets,
      setUniforms: module.setUniforms,
    );
