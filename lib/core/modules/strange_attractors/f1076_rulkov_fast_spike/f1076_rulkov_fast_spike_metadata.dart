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
class F1076RulkovFastSpikeMetadata {
  static const instance = F1076RulkovFastSpikeMetadata._();
  const F1076RulkovFastSpikeMetadata._();

  String get id => 'f1076_rulkov_fast_spike';
  String get name => 'Rulkov Fast Spike';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Rulkov alpha=5.0',
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
