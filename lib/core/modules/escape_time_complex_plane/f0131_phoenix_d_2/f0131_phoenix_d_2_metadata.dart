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
class F0131PhoenixD2Metadata {
  static const instance = F0131PhoenixD2Metadata._();
  const F0131PhoenixD2Metadata._();

  String get id => 'f0131_phoenix_d_2';
  String get name => 'Phoenix d=2';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Phoenix d=2',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Phoenix_(fractal)',
    ),
  ];
}
