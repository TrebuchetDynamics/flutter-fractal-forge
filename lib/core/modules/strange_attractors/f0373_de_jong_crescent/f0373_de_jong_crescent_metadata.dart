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
class F0373DeJongCrescentMetadata {
  static const instance = F0373DeJongCrescentMetadata._();
  const F0373DeJongCrescentMetadata._();

  String get id => 'f0373_de_jong_crescent';
  String get name => 'de Jong Crescent';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-1.24 b=-1.25 c=-1.88 d=-1.11',
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
