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
class F0063MooreSpiegelMetadata {
  static const instance = F0063MooreSpiegelMetadata._();
  const F0063MooreSpiegelMetadata._();

  String get id => 'f0063_moore_spiegel';
  String get name => 'Moore-Spiegel';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. W. Moore, E. A. Spiegel',
      title: 'A thermally excited non-linear oscillator',
      year: 1966,
      url: 'https://ui.adsabs.harvard.edu/abs/1966ApJ...143..871M',
    ),
  ];
}
