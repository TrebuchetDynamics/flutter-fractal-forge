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
class F0386DeJongCoralMetadata {
  static const instance = F0386DeJongCoralMetadata._();
  const F0386DeJongCoralMetadata._();

  String get id => 'f0386_de_jong_coral';
  String get name => 'de Jong Coral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.1 b=-1.32 c=-0.79 d=1.82',
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
