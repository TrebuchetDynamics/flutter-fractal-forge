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
class F0811SawtoothMapAlpha15Metadata {
  static const instance = F0811SawtoothMapAlpha15Metadata._();
  const F0811SawtoothMapAlpha15Metadata._();

  String get id => 'f0811_sawtooth_map_alpha_1_5';
  String get name => 'Sawtooth Map (alpha=1.5)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Walters',
      title: 'An introduction to ergodic theory',
      year: 1982,
      url: 'https://en.wikipedia.org/wiki/Sawtooth_wave',
    ),
  ];
}
