import '../autonomous_polynomial_flows/f150_liu_chen.dart';
import '../autonomous_polynomial_flows/f151_newton_leipnik.dart';
import '../autonomous_polynomial_flows/f152_bouali_attractor.dart';
import '../autonomous_polynomial_flows/f154_four_wing_attractor.dart';
import '../jerk_oscillator_flows/f146_moore_spiegel_attractor.dart';
import '../jerk_oscillator_flows/f148_arneodo_attractor.dart';
import '../jerk_oscillator_flows/f149_genesio_tesi.dart';
import '../sprott_family/f143_sprott_attractors.dart';
import '../trigonometric_symmetric_flows/f153_thomas_attractor.dart';

void main() {
  final metadata = [
    _metadata(
      F143SprottAttractors.id,
      F143SprottAttractors.displayName,
      F143SprottAttractors.category,
    ),
    _metadata(
      F146MooreSpiegelAttractor.id,
      F146MooreSpiegelAttractor.displayName,
      F146MooreSpiegelAttractor.category,
    ),
    _metadata(
      F148ArneodoAttractor.id,
      F148ArneodoAttractor.displayName,
      F148ArneodoAttractor.category,
    ),
    _metadata(
      F149GenesioTesi.id,
      F149GenesioTesi.displayName,
      F149GenesioTesi.category,
    ),
    _metadata(
      F150LiuChen.id,
      F150LiuChen.displayName,
      F150LiuChen.category,
    ),
    _metadata(
      F151NewtonLeipnik.id,
      F151NewtonLeipnik.displayName,
      F151NewtonLeipnik.category,
    ),
    _metadata(
      F152BoualiAttractor.id,
      F152BoualiAttractor.displayName,
      F152BoualiAttractor.category,
    ),
    _metadata(
      F153ThomasAttractor.id,
      F153ThomasAttractor.displayName,
      F153ThomasAttractor.category,
    ),
    _metadata(
      F154FourWingAttractor.id,
      F154FourWingAttractor.displayName,
      F154FourWingAttractor.category,
    ),
  ];

  const expected = [
    {
      'id': 'f143_sprott_attractors',
      'displayName': 'Sprott Attractors (A-Z)',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f146_moore_spiegel_attractor',
      'displayName': 'Moore-Spiegel Attractor',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f148_arneodo_attractor',
      'displayName': 'Arneodo Attractor',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f149_genesio_tesi',
      'displayName': 'Genesio-Tesi',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f150_liu_chen',
      'displayName': 'Liu-Chen',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f151_newton_leipnik',
      'displayName': 'Newton-Leipnik',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f152_bouali_attractor',
      'displayName': 'Bouali Attractor',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f153_thomas_attractor',
      'displayName': 'Thomas Attractor',
      'category': 'X. Deep Chaos & Flows',
    },
    {
      'id': 'f154_four_wing_attractor',
      'displayName': 'Four-Wing Attractor',
      'category': 'X. Deep Chaos & Flows',
    },
  ];

  if (!_sameMetadata(metadata, expected)) {
    throw StateError('Sprott and named flow metadata changed: $metadata');
  }

  final sharedMetadata = [
    F143SprottAttractors.metadata,
    F146MooreSpiegelAttractor.metadata,
    F148ArneodoAttractor.metadata,
    F149GenesioTesi.metadata,
    F150LiuChen.metadata,
    F151NewtonLeipnik.metadata,
    F152BoualiAttractor.metadata,
    F153ThomasAttractor.metadata,
    F154FourWingAttractor.metadata,
  ]
      .map((entry) => _metadata(entry.id, entry.displayName, entry.category))
      .toList();

  if (!_sameMetadata(sharedMetadata, metadata)) {
    throw StateError(
      'Shared flow reference metadata does not match static constants: '
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
