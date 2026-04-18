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
class F0716ThueMorse2dTilingMetadata {
  static const instance = F0716ThueMorse2dTilingMetadata._();
  const F0716ThueMorse2dTilingMetadata._();

  String get id => 'f0716_thue_morse_2d_tiling';
  String get name => 'Thue-Morse 2D Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Thue-Morse tiling',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Tiling and rep-tiles',
      year: 2001,
      url: 'http://paulbourke.net/geometry/tilings/',
    ),
  ];
}
