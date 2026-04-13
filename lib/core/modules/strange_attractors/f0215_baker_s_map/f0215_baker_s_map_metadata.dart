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
class F0215BakerSMapMetadata {
  static const instance = F0215BakerSMapMetadata._();
  const F0215BakerSMapMetadata._();

  String get id => 'f0215_baker_s_map';
  String get name => 'Baker&#39;s Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Baker&#39;s map',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Baker%27s_map',
    ),
  ];
}
