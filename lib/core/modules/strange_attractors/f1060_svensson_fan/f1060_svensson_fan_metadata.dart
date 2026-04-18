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
class F1060SvenssonFanMetadata {
  static const instance = F1060SvenssonFanMetadata._();
  const F1060SvenssonFanMetadata._();

  String get id => 'f1060_svensson_fan';
  String get name => 'Svensson Fan';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-1.5 b=-1.7 c=-0.3 d=-0.7',
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
