import 'package:flutter_fractals/core/models/export_options.dart';

const int defaultCustomExportWidth = 1920;
const int defaultCustomExportHeight = 1080;

int resolveCustomExportDimension({
  required String fieldText,
  required int? currentValue,
  required int fallback,
}) {
  final parsed = int.tryParse(fieldText.trim());
  if (parsed != null && parsed > 0) return parsed;
  if (currentValue != null && currentValue > 0) return currentValue;
  return fallback;
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
