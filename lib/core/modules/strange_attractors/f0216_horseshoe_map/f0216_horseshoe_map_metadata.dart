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
class F0216HorseshoeMapMetadata {
  static const instance = F0216HorseshoeMapMetadata._();
  const F0216HorseshoeMapMetadata._();

  String get id => 'f0216_horseshoe_map';
  String get name => 'Horseshoe Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Smale horseshoe',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Smale',
      title: 'Differentiable dynamical systems',
      year: 1967,
      url: 'https://doi.org/10.1090/S0002-9904-1967-11798-1',
    ),
  ];
}
