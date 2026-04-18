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
class F1206NewtonZ31Relaxed15Metadata {
  static const instance = F1206NewtonZ31Relaxed15Metadata._();
  const F1206NewtonZ31Relaxed15Metadata._();

  String get id => 'f1206_newton_z_3_1_relaxed_1_5';
  String get name => 'Newton z^3 - 1 (Relaxed 1.5)';
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
