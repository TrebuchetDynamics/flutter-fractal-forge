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
class F1045SvenssonIrisMetadata {
  static const instance = F1045SvenssonIrisMetadata._();
  const F1045SvenssonIrisMetadata._();

  String get id => 'f1045_svensson_iris';
  String get name => 'Svensson Iris';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-1.78 b=-2.05 c=-2.55 d=-0.53',
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
