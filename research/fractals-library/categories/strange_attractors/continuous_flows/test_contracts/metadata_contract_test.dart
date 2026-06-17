import '../classic_benchmark_flows/f036_lorenz_attractor.dart';
import '../classic_benchmark_flows/f037_r_ssler_attractor.dart';
import '../polynomial_named_flows/f048_rabinovich_fabrikant_equations.dart';
import '../polynomial_named_flows/f049_dadras_attractor.dart';
import '../polynomial_named_flows/f050_chen_attractor.dart';
import '../polynomial_named_flows/f051_l_chen_attractor.dart';
import '../polynomial_named_flows/f052_aizawa_attractor.dart';
import '../symmetric_cyclic_flows/f046_thomas_cyclically_symmetric_attractor.dart';
import '../symmetric_cyclic_flows/f047_halvorsen_attractor.dart';

void main() {
  final metadata = [
    _metadata(
      F036LorenzAttractor.id,
      F036LorenzAttractor.displayName,
      F036LorenzAttractor.category,
    ),
    _metadata(
      F037RSslerAttractor.id,
      F037RSslerAttractor.displayName,
      F037RSslerAttractor.category,
    ),
    _metadata(
      F046ThomasCyclicallySymmetricAttractor.id,
      F046ThomasCyclicallySymmetricAttractor.displayName,
      F046ThomasCyclicallySymmetricAttractor.category,
    ),
    _metadata(
      F047HalvorsenAttractor.id,
      F047HalvorsenAttractor.displayName,
      F047HalvorsenAttractor.category,
    ),
    _metadata(
      F048RabinovichFabrikantEquations.id,
      F048RabinovichFabrikantEquations.displayName,
      F048RabinovichFabrikantEquations.category,
    ),
    _metadata(
      F049DadrasAttractor.id,
      F049DadrasAttractor.displayName,
      F049DadrasAttractor.category,
    ),
    _metadata(
      F050ChenAttractor.id,
      F050ChenAttractor.displayName,
      F050ChenAttractor.category,
    ),
    _metadata(
      F051LChenAttractor.id,
      F051LChenAttractor.displayName,
      F051LChenAttractor.category,
    ),
    _metadata(
      F052AizawaAttractor.id,
      F052AizawaAttractor.displayName,
      F052AizawaAttractor.category,
    ),
  ];

  const expectedCategory = 'III. Strange Attractors (Chaos Theory)';
  const expected = [
    {
      'id': 'f036_lorenz_attractor',
      'displayName': 'Lorenz Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f037_r_ssler_attractor',
      'displayName': 'Rössler Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f046_thomas_cyclically_symmetric_attractor',
      'displayName': 'Thomas\' Cyclically Symmetric Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f047_halvorsen_attractor',
      'displayName': 'Halvorsen Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f048_rabinovich_fabrikant_equations',
      'displayName': 'Rabinovich-Fabrikant Equations',
      'category': expectedCategory,
    },
    {
      'id': 'f049_dadras_attractor',
      'displayName': 'Dadras Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f050_chen_attractor',
      'displayName': 'Chen Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f051_l_chen_attractor',
      'displayName': 'Lü Chen Attractor',
      'category': expectedCategory,
    },
    {
      'id': 'f052_aizawa_attractor',
      'displayName': 'Aizawa Attractor',
      'category': expectedCategory,
    },
  ];

  if (!_sameMetadata(metadata, expected)) {
    throw StateError('Continuous-flow attractor metadata changed: $metadata');
  }

  final sharedMetadata = [
    F036LorenzAttractor.metadata,
    F037RSslerAttractor.metadata,
    F046ThomasCyclicallySymmetricAttractor.metadata,
    F047HalvorsenAttractor.metadata,
    F048RabinovichFabrikantEquations.metadata,
    F049DadrasAttractor.metadata,
    F050ChenAttractor.metadata,
    F051LChenAttractor.metadata,
    F052AizawaAttractor.metadata,
  ]
      .map((entry) => _metadata(entry.id, entry.displayName, entry.category))
      .toList();

  if (!_sameMetadata(sharedMetadata, metadata)) {
    throw StateError(
      'Shared continuous-flow metadata does not match static constants: '
      '$sharedMetadata',
    );
  }
}

Map<String, String> _metadata(String id, String displayName, String category) =>
    {
      'id': id,
      'displayName': displayName,
      'category': category,
    };

bool _sameMetadata(
  List<Map<String, String>> actual,
  List<Map<String, String>> expected,
) {
  if (actual.length != expected.length) return false;

  for (var i = 0; i < actual.length; i += 1) {
    final actualEntry = actual[i];
    final expectedEntry = expected[i];
    for (final key in expectedEntry.keys) {
      if (actualEntry[key] != expectedEntry[key]) return false;
    }
  }

  return true;
}
