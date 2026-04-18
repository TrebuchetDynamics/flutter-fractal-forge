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
class F1058SvenssonTornadoMetadata {
  static const instance = F1058SvenssonTornadoMetadata._();
  const F1058SvenssonTornadoMetadata._();

  String get id => 'f1058_svensson_tornado';
  String get name => 'Svensson Tornado';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-1.4 b=1.6 c=1.0 d=0.7',
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
