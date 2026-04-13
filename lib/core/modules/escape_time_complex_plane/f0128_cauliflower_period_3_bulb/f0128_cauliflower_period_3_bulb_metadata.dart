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
class F0128CauliflowerPeriod3BulbMetadata {
  static const instance = F0128CauliflowerPeriod3BulbMetadata._();
  const F0128CauliflowerPeriod3BulbMetadata._();

  String get id => 'f0128_cauliflower_period_3_bulb';
  String get name => 'Cauliflower (period-3 bulb)';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'mandelbrot';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Cauliflower (period-3 bulb)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
