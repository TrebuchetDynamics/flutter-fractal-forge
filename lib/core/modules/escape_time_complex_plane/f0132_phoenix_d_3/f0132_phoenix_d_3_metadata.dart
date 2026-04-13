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
class F0132PhoenixD3Metadata {
  static const instance = F0132PhoenixD3Metadata._();
  const F0132PhoenixD3Metadata._();

  String get id => 'f0132_phoenix_d_3';
  String get name => 'Phoenix d=3';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_cubic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Phoenix d=3',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Phoenix_(fractal)',
    ),
  ];
}
