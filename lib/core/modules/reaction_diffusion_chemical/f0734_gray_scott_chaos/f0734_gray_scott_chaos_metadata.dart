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
class F0734GrayScottChaosMetadata {
  static const instance = F0734GrayScottChaosMetadata._();
  const F0734GrayScottChaosMetadata._();

  String get id => 'f0734_gray_scott_chaos';
  String get name => 'Gray-Scott Chaos';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Gray-Scott F=0.026 k=0.051',
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
