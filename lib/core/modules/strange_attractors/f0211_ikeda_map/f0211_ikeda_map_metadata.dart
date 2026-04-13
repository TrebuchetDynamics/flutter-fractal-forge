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
class F0211IkedaMapMetadata {
  static const instance = F0211IkedaMapMetadata._();
  const F0211IkedaMapMetadata._();

  String get id => 'f0211_ikeda_map';
  String get name => 'Ikeda Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Ikeda',
      title: 'Multiple-valued stationary state and its instability',
      year: 1979,
      url: 'https://doi.org/10.1016/0030-4018(79)90090-7',
    ),
  ];
}
