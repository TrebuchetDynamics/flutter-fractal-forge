import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/burning_ship_module.dart';
import 'package:flutter_fractals/core/modules/julia_module.dart';
import 'package:flutter_fractals/core/modules/mandelbrot_module.dart';
import 'package:flutter_fractals/core/modules/mandelbulb_module.dart';

class ModuleRegistry {
  final List<FractalModule> modules;

  ModuleRegistry() : modules = [
    buildMandelbrotModule(),
    buildJuliaModule(),
    buildBurningShipModule(),
    buildMandelbulbModule(),
  ];

  FractalModule byId(String id) {
    return modules.firstWhere((module) => module.id == id);
  }
}
