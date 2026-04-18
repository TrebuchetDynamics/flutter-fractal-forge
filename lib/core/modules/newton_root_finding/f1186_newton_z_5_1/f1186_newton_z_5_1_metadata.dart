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
class F1186NewtonZ51Metadata {
  static const instance = F1186NewtonZ51Metadata._();
  const F1186NewtonZ51Metadata._();

  String get id => 'f1186_newton_z_5_1';
  String get name => 'Newton z^5 - 1';
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
