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
class F1207NewtonZ31Relaxed20Metadata {
  static const instance = F1207NewtonZ31Relaxed20Metadata._();
  const F1207NewtonZ31Relaxed20Metadata._();

  String get id => 'f1207_newton_z_3_1_relaxed_2_0';
  String get name => 'Newton z^3 - 1 (Relaxed 2.0)';
  String get category => 'Newton / Root-Finding';

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
