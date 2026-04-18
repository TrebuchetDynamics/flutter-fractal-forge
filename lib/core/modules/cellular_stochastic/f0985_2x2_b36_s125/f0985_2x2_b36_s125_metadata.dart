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
class F09852x2B36S125Metadata {
  static const instance = F09852x2B36S125Metadata._();
  const F09852x2B36S125Metadata._();

  String get id => 'f0985_2x2_b36_s125';
  String get name => '2x2 (B36/S125)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B36-S125',
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
