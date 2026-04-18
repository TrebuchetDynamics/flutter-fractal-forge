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
class F0824SinaiMapMetadata {
  static const instance = F0824SinaiMapMetadata._();
  const F0824SinaiMapMetadata._();

  String get id => 'f0824_sinai_map';
  String get name => 'Sinai Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. G. Sinai',
      title: 'Markov partitions and Y-diffeomorphisms',
      year: 1968,
      url: 'https://en.wikipedia.org/wiki/Anosov_diffeomorphism',
    ),
  ];
}
