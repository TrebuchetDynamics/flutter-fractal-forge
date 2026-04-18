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
class F0828HenonHeilesMapDiscreteMetadata {
  static const instance = F0828HenonHeilesMapDiscreteMetadata._();
  const F0828HenonHeilesMapDiscreteMetadata._();

  String get id => 'f0828_henon_heiles_map_discrete';
  String get name => 'Henon-Heiles Map (Discrete)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Hénon, C. Heiles',
      title: 'The applicability of the third integral of motion: some numerical experiments',
      year: 1964,
      url: 'https://doi.org/10.1086/109234',
    ),
  ];
}
