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
class F0168MisiurewiczM21Metadata {
  static const instance = F0168MisiurewiczM21Metadata._();
  const F0168MisiurewiczM21Metadata._();

  String get id => 'f0168_misiurewicz_m_2_1';
  String get name => 'Misiurewicz M_{2,1}';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Misiurewicz -2',
    'c=-2.0+0.0i',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Julia set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Julia_set',
    ),
    Citation(
      author: 'Robert Munafo',
      title: 'Mu-Ency: Julia set catalog',
      year: 2023,
      url: 'https://mrob.com/pub/muency/julia.html',
    ),
  ];
}
