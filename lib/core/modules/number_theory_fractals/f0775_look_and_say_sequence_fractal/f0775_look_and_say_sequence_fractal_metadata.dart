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
class F0775LookAndSaySequenceFractalMetadata {
  static const instance = F0775LookAndSaySequenceFractalMetadata._();
  const F0775LookAndSaySequenceFractalMetadata._();

  String get id => 'f0775_look_and_say_sequence_fractal';
  String get name => 'Look-and-Say Sequence Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'audioactive',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. H. Conway',
      title: 'The weird and wonderful chemistry of audioactive decay',
      year: 1987,
      url: 'https://mathworld.wolfram.com/Look-and-SaySequence.html',
    ),
  ];
}
