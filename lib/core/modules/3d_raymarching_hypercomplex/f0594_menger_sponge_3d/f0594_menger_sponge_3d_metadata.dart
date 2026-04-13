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
class F0594MengerSponge3dMetadata {
  static const instance = F0594MengerSponge3dMetadata._();
  const F0594MengerSponge3dMetadata._();

  String get id => 'f0594_menger_sponge_3d';
  String get name => 'Menger Sponge 3D';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Menger Sponge 3D',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
