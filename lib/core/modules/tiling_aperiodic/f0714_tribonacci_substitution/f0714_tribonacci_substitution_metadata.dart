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
class F0714TribonacciSubstitutionMetadata {
  static const instance = F0714TribonacciSubstitutionMetadata._();
  const F0714TribonacciSubstitutionMetadata._();

  String get id => 'f0714_tribonacci_substitution';
  String get name => 'Tribonacci Substitution';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Tribonacci',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Tiling and rep-tiles',
      year: 2001,
      url: 'http://paulbourke.net/geometry/tilings/',
    ),
  ];
}
