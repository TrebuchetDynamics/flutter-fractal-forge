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
class F1043SvenssonStormMetadata {
  static const instance = F1043SvenssonStormMetadata._();
  const F1043SvenssonStormMetadata._();

  String get id => 'f1043_svensson_storm';
  String get name => 'Svensson Storm';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.0 b=2.0 c=1.0 d=1.0',
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
