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
class F1050SvenssonBayMetadata {
  static const instance = F1050SvenssonBayMetadata._();
  const F1050SvenssonBayMetadata._();

  String get id => 'f1050_svensson_bay';
  String get name => 'Svensson Bay';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-1.55 b=1.55 c=-2.4 d=-2.4',
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
