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
class F0711SpectreAperiodicMonotileMetadata {
  static const instance = F0711SpectreAperiodicMonotileMetadata._();
  const F0711SpectreAperiodicMonotileMetadata._();

  String get id => 'f0711_spectre_aperiodic_monotile';
  String get name => 'Spectre Aperiodic Monotile';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Chiral einstein',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Smith, J. S. Myers, C. S. Kaplan, C. Goodman-Strauss',
      title: 'A chiral aperiodic monotile',
      year: 2023,
      url: 'https://arxiv.org/abs/2305.17743',
    ),
  ];
}
