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
class F0275MengerSponge2dCarpetMetadata {
  static const instance = F0275MengerSponge2dCarpetMetadata._();
  const F0275MengerSponge2dCarpetMetadata._();

  String get id => 'f0275_menger_sponge_2d_carpet';
  String get name => 'Menger Sponge 2D (Carpet+)';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Menger 2D',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Menger carpet',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
