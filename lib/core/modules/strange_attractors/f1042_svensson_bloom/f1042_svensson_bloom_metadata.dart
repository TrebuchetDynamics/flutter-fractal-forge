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
class F1042SvenssonBloomMetadata {
  static const instance = F1042SvenssonBloomMetadata._();
  const F1042SvenssonBloomMetadata._();

  String get id => 'f1042_svensson_bloom';
  String get name => 'Svensson Bloom';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.337 b=-2.337 c=0.533 d=1.378',
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
