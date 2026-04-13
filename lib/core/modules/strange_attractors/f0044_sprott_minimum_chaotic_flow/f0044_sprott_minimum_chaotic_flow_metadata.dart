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
class F0044SprottMinimumChaoticFlowMetadata {
  static const instance = F0044SprottMinimumChaoticFlowMetadata._();
  const F0044SprottMinimumChaoticFlowMetadata._();

  String get id => 'f0044_sprott_minimum_chaotic_flow';
  String get name => 'Sprott Minimum Chaotic Flow';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Minimum-Chaotic-Flow',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Elegant Chaos: Algebraically Simple Chaotic Flows',
      year: 2010,
      url: 'https://sprott.physics.wisc.edu/pubs/paper356.pdf',
    ),
  ];
}
