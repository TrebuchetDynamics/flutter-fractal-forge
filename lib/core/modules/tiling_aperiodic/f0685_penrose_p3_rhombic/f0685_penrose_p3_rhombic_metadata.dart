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
class F0685PenroseP3RhombicMetadata {
  static const instance = F0685PenroseP3RhombicMetadata._();
  const F0685PenroseP3RhombicMetadata._();

  String get id => 'f0685_penrose_p3_rhombic';
  String get name => 'Penrose P3 Rhombic';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'P3',
    'Penrose rhombic',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Penrose',
      title: 'The Role of Aesthetics in Pure and Applied Mathematical Research',
      year: 1974,
      url: 'https://en.wikipedia.org/wiki/Penrose_tiling',
    ),
  ];
}
