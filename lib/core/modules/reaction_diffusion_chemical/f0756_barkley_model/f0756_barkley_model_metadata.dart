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
class F0756BarkleyModelMetadata {
  static const instance = F0756BarkleyModelMetadata._();
  const F0756BarkleyModelMetadata._();

  String get id => 'f0756_barkley_model';
  String get name => 'Barkley Model';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Barkley',
      title: 'A model for fast computer simulation of waves in excitable media',
      year: 1991,
      url: 'https://doi.org/10.1016/0167-2789(91)90194-E',
    ),
  ];
}
