// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class F0212StandardMapChirikovMetadata {
  static const instance = F0212StandardMapChirikovMetadata._();
  const F0212StandardMapChirikovMetadata._();

  String get id => 'f0212_standard_map_chirikov';
  String get name => 'Standard Map (Chirikov)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Chirikov-Taylor map',
    'kicked rotor',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. V. Chirikov',
      title: 'A universal instability of many-dimensional oscillator systems',
      year: 1979,
      url: 'https://doi.org/10.1016/0370-1573(79)90023-1',
    ),
  ];
}
