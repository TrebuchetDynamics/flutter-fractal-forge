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
class F0821StandardMapChirikovK097Metadata {
  static const instance = F0821StandardMapChirikovK097Metadata._();
  const F0821StandardMapChirikovK097Metadata._();

  String get id => 'f0821_standard_map_chirikov_k_0_97';
  String get name => 'Standard Map (Chirikov K=0.97)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Chirikov standard',
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
