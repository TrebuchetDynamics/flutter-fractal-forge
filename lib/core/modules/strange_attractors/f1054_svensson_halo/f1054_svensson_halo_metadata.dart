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
class F1054SvenssonHaloMetadata {
  static const instance = F1054SvenssonHaloMetadata._();
  const F1054SvenssonHaloMetadata._();

  String get id => 'f1054_svensson_halo';
  String get name => 'Svensson Halo';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.5 b=5.0 c=-1.9 d=1.0',
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
