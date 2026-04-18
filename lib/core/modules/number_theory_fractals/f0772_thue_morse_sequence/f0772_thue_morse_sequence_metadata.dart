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
class F0772ThueMorseSequenceMetadata {
  static const instance = F0772ThueMorseSequenceMetadata._();
  const F0772ThueMorseSequenceMetadata._();

  String get id => 'f0772_thue_morse_sequence';
  String get name => 'Thue-Morse Sequence';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Thue-Morse',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Thue',
      title: 'Über unendliche Zeichenreihen',
      year: 1906,
      url: 'https://mathworld.wolfram.com/Thue-MorseSequence.html',
    ),
  ];
}
