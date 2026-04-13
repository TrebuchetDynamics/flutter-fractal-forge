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
class F0056AizawaAttractorMetadata {
  static const instance = F0056AizawaAttractorMetadata._();
  const F0056AizawaAttractorMetadata._();

  String get id => 'f0056_aizawa_attractor';
  String get name => 'Aizawa Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. Aizawa',
      title: 'Aizawa attractor (classical catalog)',
      year: 1982,
      url: 'https://www.algosome.com/articles/aizawa-attractor-chaos.html',
    ),
  ];
}
