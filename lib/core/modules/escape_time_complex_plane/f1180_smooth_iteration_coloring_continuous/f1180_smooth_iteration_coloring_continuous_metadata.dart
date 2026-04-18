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
class F1180SmoothIterationColoringContinuousMetadata {
  static const instance = F1180SmoothIterationColoringContinuousMetadata._();
  const F1180SmoothIterationColoringContinuousMetadata._();

  String get id => 'f1180_smooth_iteration_coloring_continuous';
  String get name => 'Smooth Iteration Coloring (Continuous)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'continuous coloring',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'F. Hege',
      title: 'Smooth iteration counts for fractals',
      year: 1996,
      url: 'https://en.wikipedia.org/wiki/Mandelbrot_set#Smooth_coloring',
    ),
  ];
}
