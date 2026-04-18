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
class F1047SvenssonCoralMetadata {
  static const instance = F1047SvenssonCoralMetadata._();
  const F1047SvenssonCoralMetadata._();

  String get id => 'f1047_svensson_coral';
  String get name => 'Svensson Coral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-1.97 b=1.81 c=0.82 d=-1.13',
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
