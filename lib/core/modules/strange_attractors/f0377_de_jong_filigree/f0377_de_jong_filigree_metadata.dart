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
class F0377DeJongFiligreeMetadata {
  static const instance = F0377DeJongFiligreeMetadata._();
  const F0377DeJongFiligreeMetadata._();

  String get id => 'f0377_de_jong_filigree';
  String get name => 'de Jong Filigree';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.7 b=-1.7 c=1.7 d=-1.7',
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
