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
class F0276MengerSponge3dMetadata {
  static const instance = F0276MengerSponge3dMetadata._();
  const F0276MengerSponge3dMetadata._();

  String get id => 'f0276_menger_sponge_3d';
  String get name => 'Menger Sponge 3D';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Menger cube',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Menger sponge 3D',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
