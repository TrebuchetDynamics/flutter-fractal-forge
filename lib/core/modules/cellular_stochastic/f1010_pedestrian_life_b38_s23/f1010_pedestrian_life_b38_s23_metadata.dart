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
class F1010PedestrianLifeB38S23Metadata {
  static const instance = F1010PedestrianLifeB38S23Metadata._();
  const F1010PedestrianLifeB38S23Metadata._();

  String get id => 'f1010_pedestrian_life_b38_s23';
  String get name => 'Pedestrian Life (B38/S23)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B38-S23',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}
