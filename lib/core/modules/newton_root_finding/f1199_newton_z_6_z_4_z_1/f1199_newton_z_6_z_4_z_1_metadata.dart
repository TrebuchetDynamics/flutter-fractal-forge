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
class F1199NewtonZ6Z4Z1Metadata {
  static const instance = F1199NewtonZ6Z4Z1Metadata._();
  const F1199NewtonZ6Z4Z1Metadata._();

  String get id => 'f1199_newton_z_6_z_4_z_1';
  String get name => 'Newton z^6 - z^4 + z - 1';
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
