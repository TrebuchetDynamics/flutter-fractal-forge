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
class F0371DeJongPeacockMetadata {
  static const instance = F0371DeJongPeacockMetadata._();
  const F0371DeJongPeacockMetadata._();

  String get id => 'f0371_de_jong_peacock';
  String get name => 'de Jong Peacock';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=2.01 b=-2.53 c=1.61 d=-0.33',
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
