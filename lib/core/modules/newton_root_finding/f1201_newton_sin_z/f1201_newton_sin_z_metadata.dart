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
class F1201NewtonSinZMetadata {
  static const instance = F1201NewtonSinZMetadata._();
  const F1201NewtonSinZMetadata._();

  String get id => 'f1201_newton_sin_z';
  String get name => 'Newton sin(z)';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Newton sine',
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
