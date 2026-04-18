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
class F1002BugsB3567S15678Metadata {
  static const instance = F1002BugsB3567S15678Metadata._();
  const F1002BugsB3567S15678Metadata._();

  String get id => 'f1002_bugs_b3567_s15678';
  String get name => 'Bugs (B3567/S15678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3567-S15678',
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
