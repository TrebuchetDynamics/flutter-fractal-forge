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
class F0990AnnealB4678S35678Metadata {
  static const instance = F0990AnnealB4678S35678Metadata._();
  const F0990AnnealB4678S35678Metadata._();

  String get id => 'f0990_anneal_b4678_s35678';
  String get name => 'Anneal (B4678/S35678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B4678-S35678',
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
