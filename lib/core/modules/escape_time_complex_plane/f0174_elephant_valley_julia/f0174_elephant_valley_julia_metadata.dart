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
class F0174ElephantValleyJuliaMetadata {
  static const instance = F0174ElephantValleyJuliaMetadata._();
  const F0174ElephantValleyJuliaMetadata._();

  String get id => 'f0174_elephant_valley_julia';
  String get name => 'Elephant Valley Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'elephant valley',
    'c=0.25+0.0i',
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
