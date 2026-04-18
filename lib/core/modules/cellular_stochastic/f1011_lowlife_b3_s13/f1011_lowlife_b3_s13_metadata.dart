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
class F1011LowlifeB3S13Metadata {
  static const instance = F1011LowlifeB3S13Metadata._();
  const F1011LowlifeB3S13Metadata._();

  String get id => 'f1011_lowlife_b3_s13';
  String get name => 'LowLife (B3/S13)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3-S13',
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
