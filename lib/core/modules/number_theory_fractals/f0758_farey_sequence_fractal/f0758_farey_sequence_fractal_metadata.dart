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
class F0758FareySequenceFractalMetadata {
  static const instance = F0758FareySequenceFractalMetadata._();
  const F0758FareySequenceFractalMetadata._();

  String get id => 'f0758_farey_sequence_fractal';
  String get name => 'Farey Sequence Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Farey',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Farey',
      title: 'On a curious property of vulgar fractions',
      year: 1816,
      url: 'https://mathworld.wolfram.com/FareySequence.html',
    ),
  ];
}
