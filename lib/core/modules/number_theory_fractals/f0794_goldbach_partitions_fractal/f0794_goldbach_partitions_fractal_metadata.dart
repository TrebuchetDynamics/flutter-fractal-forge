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
class F0794GoldbachPartitionsFractalMetadata {
  static const instance = F0794GoldbachPartitionsFractalMetadata._();
  const F0794GoldbachPartitionsFractalMetadata._();

  String get id => 'f0794_goldbach_partitions_fractal';
  String get name => 'Goldbach Partitions Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Goldbach',
      title: 'Letter to Euler',
      year: 1742,
      url: 'https://mathworld.wolfram.com/GoldbachConjecture.html',
    ),
  ];
}
