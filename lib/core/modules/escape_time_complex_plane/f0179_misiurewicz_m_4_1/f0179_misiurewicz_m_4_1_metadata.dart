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
class F0179MisiurewiczM41Metadata {
  static const instance = F0179MisiurewiczM41Metadata._();
  const F0179MisiurewiczM41Metadata._();

  String get id => 'f0179_misiurewicz_m_4_1';
  String get name => 'Misiurewicz M_{4,1}';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Misiurewicz 4,1',
    'c=-0.1011+0.9563i',
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
