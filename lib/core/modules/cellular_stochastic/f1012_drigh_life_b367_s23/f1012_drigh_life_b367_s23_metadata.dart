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
class F1012DrighLifeB367S23Metadata {
  static const instance = F1012DrighLifeB367S23Metadata._();
  const F1012DrighLifeB367S23Metadata._();

  String get id => 'f1012_drigh_life_b367_s23';
  String get name => 'Drigh Life (B367/S23)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B367-S23',
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
