// GENERATED — reviewed escape-variant power renderer promotions.
// Source: research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

enum SharedEscapePowerFamily { tricorn, burningShip }

class SharedEscapePowerCatalogEntry {
  final String id;
  final String name;
  final SharedEscapePowerFamily family;
  final double power;

  const SharedEscapePowerCatalogEntry({
    required this.id,
    required this.name,
    required this.family,
    required this.power,
  });
}

const List<SharedEscapePowerCatalogEntry> sharedEscapePowerCatalogEntries = [
  SharedEscapePowerCatalogEntry(
      id: 'f0106_tricorn_d_9',
      name: 'Tricorn d=9',
      family: SharedEscapePowerFamily.tricorn,
      power: 9.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0107_tricorn_d_10',
      name: 'Tricorn d=10',
      family: SharedEscapePowerFamily.tricorn,
      power: 10.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0108_tricorn_d_11',
      name: 'Tricorn d=11',
      family: SharedEscapePowerFamily.tricorn,
      power: 11.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0109_tricorn_d_12',
      name: 'Tricorn d=12',
      family: SharedEscapePowerFamily.tricorn,
      power: 12.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0110_tricorn_d_13',
      name: 'Tricorn d=13',
      family: SharedEscapePowerFamily.tricorn,
      power: 13.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0111_tricorn_d_14',
      name: 'Tricorn d=14',
      family: SharedEscapePowerFamily.tricorn,
      power: 14.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0112_tricorn_d_15',
      name: 'Tricorn d=15',
      family: SharedEscapePowerFamily.tricorn,
      power: 15.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0138_tricorn_z_1_5',
      name: 'Tricorn z^1.5',
      family: SharedEscapePowerFamily.tricorn,
      power: 1.5),
  SharedEscapePowerCatalogEntry(
      id: 'f0139_tricorn_z_2_5',
      name: 'Tricorn z^2.5',
      family: SharedEscapePowerFamily.tricorn,
      power: 2.5),
  SharedEscapePowerCatalogEntry(
      id: 'f0113_burning_ship_d_7',
      name: 'Burning Ship d=7',
      family: SharedEscapePowerFamily.burningShip,
      power: 7.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0114_burning_ship_d_8',
      name: 'Burning Ship d=8',
      family: SharedEscapePowerFamily.burningShip,
      power: 8.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0115_burning_ship_d_9',
      name: 'Burning Ship d=9',
      family: SharedEscapePowerFamily.burningShip,
      power: 9.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0116_burning_ship_d_10',
      name: 'Burning Ship d=10',
      family: SharedEscapePowerFamily.burningShip,
      power: 10.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0117_burning_ship_d_11',
      name: 'Burning Ship d=11',
      family: SharedEscapePowerFamily.burningShip,
      power: 11.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0118_burning_ship_d_12',
      name: 'Burning Ship d=12',
      family: SharedEscapePowerFamily.burningShip,
      power: 12.0),
  SharedEscapePowerCatalogEntry(
      id: 'f0140_burning_ship_z_2_5',
      name: 'Burning Ship z^2.5',
      family: SharedEscapePowerFamily.burningShip,
      power: 2.5),
  SharedEscapePowerCatalogEntry(
      id: 'f0141_burning_ship_z_1_5',
      name: 'Burning Ship z^1.5',
      family: SharedEscapePowerFamily.burningShip,
      power: 1.5),
];

List<FractalModule> buildSharedEscapePowerCatalogModules() =>
    sharedEscapePowerCatalogEntries
        .map(_buildSharedEscapePowerModule)
        .toList(growable: false);

FractalModule _buildSharedEscapePowerModule(
    SharedEscapePowerCatalogEntry entry) {
  return buildEscapeTimeModule(EscapeTimeConfig(
    id: entry.id,
    name: entry.name,
    shaderAsset: _shaderAsset(entry.family),
    defaultIterations: 220,
    defaultBailout: 4.0,
    defaultCenterX:
        entry.family == SharedEscapePowerFamily.burningShip ? -0.5 : 0.0,
    defaultCenterY:
        entry.family == SharedEscapePowerFamily.burningShip ? -0.5 : 0.0,
    defaultZoom:
        entry.family == SharedEscapePowerFamily.burningShip ? 0.5 : 1.0,
    extraParams: [
      FractalParameter(
        id: 'power',
        label: (_) => 'Power',
        type: FractalParamType.float,
        min: 1.0,
        max: 16.0,
        step: 0.1,
        defaultValue: entry.power,
      ),
    ],
  ));
}

String _shaderAsset(SharedEscapePowerFamily family) {
  return switch (family) {
    SharedEscapePowerFamily.tricorn =>
      'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag',
    SharedEscapePowerFamily.burningShip =>
      'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag',
  };
}
