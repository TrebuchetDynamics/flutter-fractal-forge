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
class F0807TentMapMu2Metadata {
  static const instance = F0807TentMapMu2Metadata._();
  const F0807TentMapMu2Metadata._();

  String get id => 'f0807_tent_map_mu_2';
  String get name => 'Tent Map (mu=2)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'tent r=2',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Lasota, M. C. Mackey',
      title: 'Chaos, fractals, and noise: stochastic aspects of dynamics',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/Tent_map',
    ),
  ];
}
