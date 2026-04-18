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
class F0774RudinShapiroSequenceMetadata {
  static const instance = F0774RudinShapiroSequenceMetadata._();
  const F0774RudinShapiroSequenceMetadata._();

  String get id => 'f0774_rudin_shapiro_sequence';
  String get name => 'Rudin-Shapiro Sequence';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Rudin-Shapiro',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'H. S. Shapiro',
      title: 'Extremal problems for polynomials and power series',
      year: 1951,
      url: 'https://mathworld.wolfram.com/Rudin-ShapiroSequence.html',
    ),
  ];
}
