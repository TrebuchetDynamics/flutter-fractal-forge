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
class F1074RulkovChaosMetadata {
  static const instance = F1074RulkovChaosMetadata._();
  const F1074RulkovChaosMetadata._();

  String get id => 'f1074_rulkov_chaos';
  String get name => 'Rulkov Chaos';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Rulkov alpha=4.6',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'N. F. Rulkov',
      title: 'Modeling of spiking-bursting neural behavior using two-dimensional map',
      year: 2002,
      url: 'https://doi.org/10.1103/PhysRevE.65.041922',
    ),
  ];
}
