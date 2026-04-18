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
class F0986GnarlB1S1Metadata {
  static const instance = F0986GnarlB1S1Metadata._();
  const F0986GnarlB1S1Metadata._();

  String get id => 'f0986_gnarl_b1_s1';
  String get name => 'Gnarl (B1/S1)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B1-S1',
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
