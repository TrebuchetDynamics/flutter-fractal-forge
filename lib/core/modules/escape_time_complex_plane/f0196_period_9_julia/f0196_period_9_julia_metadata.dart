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
class F0196Period9JuliaMetadata {
  static const instance = F0196Period9JuliaMetadata._();
  const F0196Period9JuliaMetadata._();

  String get id => 'f0196_period_9_julia';
  String get name => 'Period-9 Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'period 9',
    'c=-1.3811+0.0i',
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
