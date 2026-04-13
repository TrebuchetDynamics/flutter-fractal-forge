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
class F0139TricornZ25Metadata {
  static const instance = F0139TricornZ25Metadata._();
  const F0139TricornZ25Metadata._();

  String get id => 'f0139_tricorn_z_2_5';
  String get name => 'Tricorn z^2.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Tricorn z^2.5',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Tricorn_(mathematics)',
    ),
  ];
}
