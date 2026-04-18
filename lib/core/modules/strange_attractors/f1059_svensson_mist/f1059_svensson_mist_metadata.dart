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
class F1059SvenssonMistMetadata {
  static const instance = F1059SvenssonMistMetadata._();
  const F1059SvenssonMistMetadata._();

  String get id => 'f1059_svensson_mist';
  String get name => 'Svensson Mist';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-0.2 b=-1.1 c=-0.5 d=1.3',
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
