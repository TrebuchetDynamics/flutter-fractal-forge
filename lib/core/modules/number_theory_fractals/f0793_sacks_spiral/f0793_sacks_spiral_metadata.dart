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
class F0793SacksSpiralMetadata {
  static const instance = F0793SacksSpiralMetadata._();
  const F0793SacksSpiralMetadata._();

  String get id => 'f0793_sacks_spiral';
  String get name => 'Sacks Spiral';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Sacks',
      title: 'Number spiral',
      year: 1994,
      url: 'http://www.numberspiral.com/',
    ),
  ];
}
