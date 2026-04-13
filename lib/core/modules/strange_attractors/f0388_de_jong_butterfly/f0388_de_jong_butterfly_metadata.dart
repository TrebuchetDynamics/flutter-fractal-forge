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
class F0388DeJongButterflyMetadata {
  static const instance = F0388DeJongButterflyMetadata._();
  const F0388DeJongButterflyMetadata._();

  String get id => 'f0388_de_jong_butterfly';
  String get name => 'de Jong Butterfly';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-1.0 b=-1.8 c=-1.9 d=-1.4',
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
