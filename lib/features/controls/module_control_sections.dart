import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_style_controls.dart';

/// Extra control sections keyed by module id.
///
/// A section is a widget, so it stays in this layer; `FractalModule` declares
/// data only. Control surfaces look a section up here instead of naming
/// modules, so a new module adds one entry and no surface changes.
final Map<String, WidgetBuilder> moduleControlSections = {
  'number_wall': (_) => const NumberWallRandomizationControls(),
};
