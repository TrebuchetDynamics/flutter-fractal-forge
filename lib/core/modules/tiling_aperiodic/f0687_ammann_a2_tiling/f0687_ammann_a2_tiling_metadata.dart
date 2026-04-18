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
class F0687AmmannA2TilingMetadata {
  static const instance = F0687AmmannA2TilingMetadata._();
  const F0687AmmannA2TilingMetadata._();

  String get id => 'f0687_ammann_a2_tiling';
  String get name => 'Ammann A2 Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Ammann, B. Grünbaum, G. C. Shephard',
      title: 'Aperiodic tiles',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Ammann%E2%80%93Beenker_tiling',
    ),
  ];
}
