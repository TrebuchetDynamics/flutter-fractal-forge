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
class F0710TurtleAperiodicMonotileMetadata {
  static const instance = F0710TurtleAperiodicMonotileMetadata._();
  const F0710TurtleAperiodicMonotileMetadata._();

  String get id => 'f0710_turtle_aperiodic_monotile';
  String get name => 'Turtle Aperiodic Monotile';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Turtle tile',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Smith, J. S. Myers, C. S. Kaplan, C. Goodman-Strauss',
      title: 'An aperiodic monotile',
      year: 2023,
      url: 'https://arxiv.org/abs/2303.10798',
    ),
  ];
}
