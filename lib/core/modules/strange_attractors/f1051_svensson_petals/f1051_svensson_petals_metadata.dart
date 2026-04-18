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
class F1051SvenssonPetalsMetadata {
  static const instance = F1051SvenssonPetalsMetadata._();
  const F1051SvenssonPetalsMetadata._();

  String get id => 'f1051_svensson_petals';
  String get name => 'Svensson Petals';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.7 b=5.0 c=-1.9 d=1.0',
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
