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
class F0731GrayScottBubblesMetadata {
  static const instance = F0731GrayScottBubblesMetadata._();
  const F0731GrayScottBubblesMetadata._();

  String get id => 'f0731_gray_scott_bubbles';
  String get name => 'Gray-Scott Bubbles';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Gray-Scott F=0.098 k=0.057',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. E. Pearson',
      title: 'Complex patterns in a simple system',
      year: 1993,
      url: 'https://doi.org/10.1126/science.261.5118.189',
    ),
    Citation(
      author: 'P. Gray, S. K. Scott',
      title: 'Chemical oscillations and instabilities: non-linear chemical kinetics',
      year: 1990,
      url: 'https://doi.org/10.1093/oso/9780198556466.001.0001',
    ),
  ];
}
