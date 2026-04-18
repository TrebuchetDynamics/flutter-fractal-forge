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
class F1232EllipticFunctionJuliaMetadata {
  static const instance = F1232EllipticFunctionJuliaMetadata._();
  const F1232EllipticFunctionJuliaMetadata._();

  String get id => 'f1232_elliptic_function_julia';
  String get name => 'Elliptic Function Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
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
