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
class F0769CollatzConjectureTreeMetadata {
  static const instance = F0769CollatzConjectureTreeMetadata._();
  const F0769CollatzConjectureTreeMetadata._();

  String get id => 'f0769_collatz_conjecture_tree';
  String get name => 'Collatz Conjecture Tree';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Lagarias',
      title: 'The 3x+1 problem and its generalisations',
      year: 1985,
      url: 'https://doi.org/10.2307/2322189',
    ),
  ];
}
