import 'package:flutter_fractals/core/models/export_options.dart';

const int defaultCustomExportWidth = 1920;
const int defaultCustomExportHeight = 1080;

/// Provenance for the custom export dimension that wins resolution.
enum CustomExportDimensionSource {
  fieldText,
  currentValue,
  fallback,
}

/// Replayable result of resolving one custom export dimension.
///
/// The export model clamps target dimensions later, but the sheet summary and
/// submission payload read [ExportOptions.customWidth]/customHeight directly.
/// Keep that boundary normalized too so all export dimension paths share the
/// same safety contract.
final class CustomExportDimensionResolution {
  const CustomExportDimensionResolution({
    required this.value,
    required this.source,
    required this.wasClamped,
  });

  final int value;
  final CustomExportDimensionSource source;
  final bool wasClamped;
}

CustomExportDimensionResolution resolveCustomExportDimensionPlan({
  required String fieldText,
  required int? currentValue,
  required int fallback,
}) {
  final parsed = int.tryParse(fieldText.trim());
  return _normalizeCustomExportDimension(
        parsed,
        source: CustomExportDimensionSource.fieldText,
      ) ??
      _normalizeCustomExportDimension(
        currentValue,
        source: CustomExportDimensionSource.currentValue,
      ) ??
      _normalizeFallbackCustomExportDimension(fallback);
}

int resolveCustomExportDimension({
  required String fieldText,
  required int? currentValue,
  required int fallback,
}) {
  return resolveCustomExportDimensionPlan(
    fieldText: fieldText,
    currentValue: currentValue,
    fallback: fallback,
  ).value;
}

CustomExportDimensionResolution? _normalizeCustomExportDimension(
  int? value, {
  required CustomExportDimensionSource source,
}) {
  final normalized = ExportDimensionPolicy.positiveCustomDimension(value);
  if (normalized == null) return null;

  return CustomExportDimensionResolution(
    value: normalized,
    source: source,
    wasClamped: normalized != value,
  );
}

CustomExportDimensionResolution _normalizeFallbackCustomExportDimension(
  int fallback,
) {
  final safeFallback = fallback > 0 ? fallback : 1;
  final normalized = ExportDimensionPolicy.positiveCustomDimension(
    safeFallback,
  )!;

  return CustomExportDimensionResolution(
    value: normalized,
    source: CustomExportDimensionSource.fallback,
    wasClamped: normalized != fallback,
  );
}

ExportOptions withResolvedCustomExportDimensions({
  required ExportOptions options,
  required String widthText,
  required String heightText,
}) {
  return options.copyWith(
    customWidth: resolveCustomExportDimension(
      fieldText: widthText,
      currentValue: options.customWidth,
      fallback: defaultCustomExportWidth,
    ),
    customHeight: resolveCustomExportDimension(
      fieldText: heightText,
      currentValue: options.customHeight,
      fallback: defaultCustomExportHeight,
    ),
  );
}
