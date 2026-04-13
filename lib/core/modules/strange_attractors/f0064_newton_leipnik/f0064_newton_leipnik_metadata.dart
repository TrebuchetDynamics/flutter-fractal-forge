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
class F0064NewtonLeipnikMetadata {
  static const instance = F0064NewtonLeipnikMetadata._();
  const F0064NewtonLeipnikMetadata._();

  String get id => 'f0064_newton_leipnik';
  String get name => 'Newton-Leipnik';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. B. Leipnik, T. A. Newton',
      title: 'Double strange attractors in rigid body motion',
      year: 1981,
      url: 'https://doi.org/10.1016/0375-9601(81)90165-9',
    ),
  ];
}
