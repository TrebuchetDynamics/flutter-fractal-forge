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
class F0808TentMapMu15Metadata {
  static const instance = F0808TentMapMu15Metadata._();
  const F0808TentMapMu15Metadata._();

  String get id => 'f0808_tent_map_mu_1_5';
  String get name => 'Tent Map (mu=1.5)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. L. Devaney',
      title: 'An introduction to chaotic dynamical systems',
      year: 1989,
      url: 'https://en.wikipedia.org/wiki/Tent_map',
    ),
  ];
}
