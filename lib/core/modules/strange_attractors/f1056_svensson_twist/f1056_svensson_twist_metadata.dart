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
class F1056SvenssonTwistMetadata {
  static const instance = F1056SvenssonTwistMetadata._();
  const F1056SvenssonTwistMetadata._();

  String get id => 'f1056_svensson_twist';
  String get name => 'Svensson Twist';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=1.5 b=-2.5 c=1.5 d=0.5',
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
