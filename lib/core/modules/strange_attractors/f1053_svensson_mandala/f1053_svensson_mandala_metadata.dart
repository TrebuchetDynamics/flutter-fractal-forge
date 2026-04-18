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
class F1053SvenssonMandalaMetadata {
  static const instance = F1053SvenssonMandalaMetadata._();
  const F1053SvenssonMandalaMetadata._();

  String get id => 'f1053_svensson_mandala';
  String get name => 'Svensson Mandala';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.34 b=2.0 c=0.2 d=0.1',
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
