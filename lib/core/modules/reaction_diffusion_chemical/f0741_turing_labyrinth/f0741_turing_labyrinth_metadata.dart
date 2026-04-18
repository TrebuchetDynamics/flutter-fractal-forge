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
class F0741TuringLabyrinthMetadata {
  static const instance = F0741TuringLabyrinthMetadata._();
  const F0741TuringLabyrinthMetadata._();

  String get id => 'f0741_turing_labyrinth';
  String get name => 'Turing Labyrinth';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'labyrinth',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. M. Turing',
      title: 'The chemical basis of morphogenesis',
      year: 1952,
      url: 'https://doi.org/10.1098/rstb.1952.0012',
    ),
  ];
}
