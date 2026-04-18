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
class F1020BrianSBrainMetadata {
  static const instance = F1020BrianSBrainMetadata._();
  const F1020BrianSBrainMetadata._();

  String get id => 'f1020_brian_s_brain';
  String get name => 'Brian\'s Brain';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'BrianBrain',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Silverman',
      title: 'Brian\'s Brain cellular automaton',
      year: 1990,
      url: 'https://en.wikipedia.org/wiki/Brian%27s_Brain',
    ),
  ];
}
