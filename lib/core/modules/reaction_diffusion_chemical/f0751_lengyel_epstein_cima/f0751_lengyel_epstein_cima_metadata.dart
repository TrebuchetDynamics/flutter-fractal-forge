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
class F0751LengyelEpsteinCimaMetadata {
  static const instance = F0751LengyelEpsteinCimaMetadata._();
  const F0751LengyelEpsteinCimaMetadata._();

  String get id => 'f0751_lengyel_epstein_cima';
  String get name => 'Lengyel-Epstein CIMA';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'CIMA',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'I. Lengyel, I. R. Epstein',
      title: 'A chemical approach to designing Turing patterns in reaction-diffusion systems',
      year: 1992,
      url: 'https://doi.org/10.1073/pnas.89.9.3977',
    ),
  ];
}
