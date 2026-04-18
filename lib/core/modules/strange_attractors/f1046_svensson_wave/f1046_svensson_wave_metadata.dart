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
class F1046SvenssonWaveMetadata {
  static const instance = F1046SvenssonWaveMetadata._();
  const F1046SvenssonWaveMetadata._();

  String get id => 'f1046_svensson_wave';
  String get name => 'Svensson Wave';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=1.4 b=1.56 c=1.4 d=6.56',
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
