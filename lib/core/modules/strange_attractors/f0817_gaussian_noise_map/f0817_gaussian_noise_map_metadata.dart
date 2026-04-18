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
class F0817GaussianNoiseMapMetadata {
  static const instance = F0817GaussianNoiseMapMetadata._();
  const F0817GaussianNoiseMapMetadata._();

  String get id => 'f0817_gaussian_noise_map';
  String get name => 'Gaussian Noise Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'S. Hata, A. S. Mikhailov',
      title: 'Pattern formation in noise',
      year: 1995,
      url: 'https://en.wikipedia.org/wiki/Map_(mathematics)',
    ),
  ];
}
