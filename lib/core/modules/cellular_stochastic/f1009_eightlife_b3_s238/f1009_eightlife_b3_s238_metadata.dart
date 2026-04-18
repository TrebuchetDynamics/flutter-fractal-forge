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
class F1009EightlifeB3S238Metadata {
  static const instance = F1009EightlifeB3S238Metadata._();
  const F1009EightlifeB3S238Metadata._();

  String get id => 'f1009_eightlife_b3_s238';
  String get name => 'EightLife (B3/S238)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3-S238',
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
