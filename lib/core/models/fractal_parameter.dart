import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

typedef LocalizedText = String Function(AppLocalizations l10n);

enum FractalParamType {
  float,
  integer,
  enumeration,
  boolean,
}

class FractalParamOption {
  final Object value;
  final LocalizedText label;

  const FractalParamOption({
    required this.value,
    required this.label,
  });
}

@immutable
class FractalParameter {
  final String id;
  final LocalizedText label;
  final FractalParamType type;
  final double min;
  final double max;
  final double step;
  final Object defaultValue;
  final List<FractalParamOption> options;

  const FractalParameter({
    required this.id,
    required this.label,
    required this.type,
    required this.min,
    required this.max,
    required this.step,
    required this.defaultValue,
    this.options = const [],
  });
}
