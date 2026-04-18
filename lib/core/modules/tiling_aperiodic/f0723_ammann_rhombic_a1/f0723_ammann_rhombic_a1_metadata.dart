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
class F0723AmmannRhombicA1Metadata {
  static const instance = F0723AmmannRhombicA1Metadata._();
  const F0723AmmannRhombicA1Metadata._();

  String get id => 'f0723_ammann_rhombic_a1';
  String get name => 'Ammann Rhombic A1';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Ammann, B. Grünbaum, G. C. Shephard',
      title: 'Aperiodic tiles',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Ammann%E2%80%93Beenker_tiling',
    ),
  ];
}
