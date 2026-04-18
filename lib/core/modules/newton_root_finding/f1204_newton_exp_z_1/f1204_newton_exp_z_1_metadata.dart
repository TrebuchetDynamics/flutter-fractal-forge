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
class F1204NewtonExpZ1Metadata {
  static const instance = F1204NewtonExpZ1Metadata._();
  const F1204NewtonExpZ1Metadata._();

  String get id => 'f1204_newton_exp_z_1';
  String get name => 'Newton exp(z) - 1';
  String get category => 'Newton / Root-Finding';
  String get family => 'transcendental_exp';

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
