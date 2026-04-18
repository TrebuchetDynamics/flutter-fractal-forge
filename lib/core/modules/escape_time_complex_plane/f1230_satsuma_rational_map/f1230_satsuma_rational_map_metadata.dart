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
class F1230SatsumaRationalMapMetadata {
  static const instance = F1230SatsumaRationalMapMetadata._();
  const F1230SatsumaRationalMapMetadata._();

  String get id => 'f1230_satsuma_rational_map';
  String get name => 'Satsuma Rational Map';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Satsuma',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Complex_dynamics',
    ),
  ];
}
