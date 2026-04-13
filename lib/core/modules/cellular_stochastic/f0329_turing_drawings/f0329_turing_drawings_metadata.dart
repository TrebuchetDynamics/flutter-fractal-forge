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
class F0329TuringDrawingsMetadata {
  static const instance = F0329TuringDrawingsMetadata._();
  const F0329TuringDrawingsMetadata._();

  String get id => 'f0329_turing_drawings';
  String get name => 'Turing Drawings';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'Turmite',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. K. Dewdney',
      title: 'Computer Recreations: Turmites',
      year: 1989,
      url: 'https://en.wikipedia.org/wiki/Turmite',
    ),
  ];
}
