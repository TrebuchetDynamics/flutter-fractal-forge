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
class F0154Period3JuliaMetadata {
  static const instance = F0154Period3JuliaMetadata._();
  const F0154Period3JuliaMetadata._();

  String get id => 'f0154_period_3_julia';
  String get name => 'Period-3 Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'period 3',
    'c=-0.12+0.74i',
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
