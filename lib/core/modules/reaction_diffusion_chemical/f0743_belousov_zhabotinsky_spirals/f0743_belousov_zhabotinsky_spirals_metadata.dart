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
class F0743BelousovZhabotinskySpiralsMetadata {
  static const instance = F0743BelousovZhabotinskySpiralsMetadata._();
  const F0743BelousovZhabotinskySpiralsMetadata._();

  String get id => 'f0743_belousov_zhabotinsky_spirals';
  String get name => 'Belousov-Zhabotinsky Spirals';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'BZ spirals',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. N. Zaikin, A. M. Zhabotinsky',
      title: 'Concentration wave propagation in two-dimensional liquid-phase self-oscillating systems',
      year: 1970,
      url: 'https://doi.org/10.1038/225535b0',
    ),
  ];
}
