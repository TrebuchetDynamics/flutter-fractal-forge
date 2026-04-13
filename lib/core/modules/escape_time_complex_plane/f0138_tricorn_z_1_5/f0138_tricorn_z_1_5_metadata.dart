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
class F0138TricornZ15Metadata {
  static const instance = F0138TricornZ15Metadata._();
  const F0138TricornZ15Metadata._();

  String get id => 'f0138_tricorn_z_1_5';
  String get name => 'Tricorn z^1.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Tricorn z^1.5',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Tricorn_(mathematics)',
    ),
  ];
}
