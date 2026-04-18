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
class F0776KolakoskiSequenceMetadata {
  static const instance = F0776KolakoskiSequenceMetadata._();
  const F0776KolakoskiSequenceMetadata._();

  String get id => 'f0776_kolakoski_sequence';
  String get name => 'Kolakoski Sequence';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. Kolakoski',
      title: 'Self-generating runs',
      year: 1965,
      url: 'https://mathworld.wolfram.com/KolakoskiSequence.html',
    ),
  ];
}
