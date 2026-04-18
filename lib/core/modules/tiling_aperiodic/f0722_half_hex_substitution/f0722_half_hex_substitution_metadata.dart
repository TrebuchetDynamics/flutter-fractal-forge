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
class F0722HalfHexSubstitutionMetadata {
  static const instance = F0722HalfHexSubstitutionMetadata._();
  const F0722HalfHexSubstitutionMetadata._();

  String get id => 'f0722_half_hex_substitution';
  String get name => 'Half-Hex Substitution';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
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
