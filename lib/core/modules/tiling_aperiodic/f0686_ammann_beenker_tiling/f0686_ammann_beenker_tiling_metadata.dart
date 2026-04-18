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
class F0686AmmannBeenkerTilingMetadata {
  static const instance = F0686AmmannBeenkerTilingMetadata._();
  const F0686AmmannBeenkerTilingMetadata._();

  String get id => 'f0686_ammann_beenker_tiling';
  String get name => 'Ammann-Beenker Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Ammann-Beenker',
    '8-fold aperiodic',
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
