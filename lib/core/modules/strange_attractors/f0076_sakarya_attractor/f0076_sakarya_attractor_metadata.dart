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
class F0076SakaryaAttractorMetadata {
  static const instance = F0076SakaryaAttractorMetadata._();
  const F0076SakaryaAttractorMetadata._();

  String get id => 'f0076_sakarya_attractor';
  String get name => 'Sakarya Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Y. Li, W. K. S. Tang, G. Chen',
      title: 'Generating hyperchaos via state feedback control',
      year: 2005,
      url: 'https://doi.org/10.1142/S0218127405013605',
    ),
  ];
}
