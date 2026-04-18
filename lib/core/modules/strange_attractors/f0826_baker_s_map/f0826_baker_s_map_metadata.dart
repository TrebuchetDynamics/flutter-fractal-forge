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
class F0826BakerSMapMetadata {
  static const instance = F0826BakerSMapMetadata._();
  const F0826BakerSMapMetadata._();

  String get id => 'f0826_baker_s_map';
  String get name => 'Baker\'s Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'bakers map',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. G. Sinai',
      title: 'Topics in ergodic theory',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/Baker%27s_map',
    ),
  ];
}
