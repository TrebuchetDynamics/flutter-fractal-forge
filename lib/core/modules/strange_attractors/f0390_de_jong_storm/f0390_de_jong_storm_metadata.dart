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
class F0390DeJongStormMetadata {
  static const instance = F0390DeJongStormMetadata._();
  const F0390DeJongStormMetadata._();

  String get id => 'f0390_de_jong_storm';
  String get name => 'de Jong Storm';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-2.24 b=-0.43 c=-0.65 d=-2.43',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}
