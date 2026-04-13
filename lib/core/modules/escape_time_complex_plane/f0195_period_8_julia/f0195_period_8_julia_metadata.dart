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
class F0195Period8JuliaMetadata {
  static const instance = F0195Period8JuliaMetadata._();
  const F0195Period8JuliaMetadata._();

  String get id => 'f0195_period_8_julia';
  String get name => 'Period-8 Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'period 8',
    'c=-1.3761+0.0i',
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
