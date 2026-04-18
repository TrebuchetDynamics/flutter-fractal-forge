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
class F1052SvenssonArcMetadata {
  static const instance = F1052SvenssonArcMetadata._();
  const F1052SvenssonArcMetadata._();

  String get id => 'f1052_svensson_arc';
  String get name => 'Svensson Arc';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=1.0 b=1.0 c=1.0 d=1.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Johnny Svensson / Paul Bourke',
      title: 'Svensson attractor',
      year: 2001,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
