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
class F1033MartinHopalongCloudMetadata {
  static const instance = F1033MartinHopalongCloudMetadata._();
  const F1033MartinHopalongCloudMetadata._();

  String get id => 'f1033_martin_hopalong_cloud';
  String get name => 'Martin Hopalong Cloud';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=7.7 b=0.13 c=8.15',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Martin / C. Pickover',
      title: 'Hopalong attractor',
      year: 1986,
      url: 'http://paulbourke.net/fractals/martin/',
    ),
  ];
}
