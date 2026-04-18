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
class F0773ThueMorse2dHeatmapMetadata {
  static const instance = F0773ThueMorse2dHeatmapMetadata._();
  const F0773ThueMorse2dHeatmapMetadata._();

  String get id => 'f0773_thue_morse_2d_heatmap';
  String get name => 'Thue-Morse 2D Heatmap';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Morse',
      title: 'Recurrent geodesics on a surface of negative curvature',
      year: 1921,
      url: 'https://doi.org/10.1090/S0002-9947-1921-1501161-8',
    ),
  ];
}
