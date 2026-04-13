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
class F0381DeJongDoubleMetadata {
  static const instance = F0381DeJongDoubleMetadata._();
  const F0381DeJongDoubleMetadata._();

  String get id => 'f0381_de_jong_double';
  String get name => 'de Jong Double';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.4 b=-2.3 c=2.4 d=2.1',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
