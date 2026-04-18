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
class F1044SvenssonLaceMetadata {
  static const instance = F1044SvenssonLaceMetadata._();
  const F1044SvenssonLaceMetadata._();

  String get id => 'f1044_svensson_lace';
  String get name => 'Svensson Lace';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=1.5 b=-1.8 c=1.6 d=0.9',
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
