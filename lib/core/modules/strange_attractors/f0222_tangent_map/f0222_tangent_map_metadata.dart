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
class F0222TangentMapMetadata {
  static const instance = F0222TangentMapMetadata._();
  const F0222TangentMapMetadata._();

  String get id => 'f0222_tangent_map';
  String get name => 'Tangent Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Tangent discrete map',
      year: 2002,
      url: 'https://paulbourke.net/fractals/chaoticmap/',
    ),
  ];
}
