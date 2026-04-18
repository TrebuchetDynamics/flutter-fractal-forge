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
class F0822StandardMapK20Metadata {
  static const instance = F0822StandardMapK20Metadata._();
  const F0822StandardMapK20Metadata._();

  String get id => 'f0822_standard_map_k_2_0';
  String get name => 'Standard Map K=2.0';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. V. Chirikov',
      title: 'Standard map',
      year: 1979,
      url: 'https://en.wikipedia.org/wiki/Standard_map',
    ),
  ];
}
