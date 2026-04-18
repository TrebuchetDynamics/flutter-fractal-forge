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
class F0744BelousovZhabotinskyTargetWavesMetadata {
  static const instance = F0744BelousovZhabotinskyTargetWavesMetadata._();
  const F0744BelousovZhabotinskyTargetWavesMetadata._();

  String get id => 'f0744_belousov_zhabotinsky_target_waves';
  String get name => 'Belousov-Zhabotinsky Target Waves';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'BZ target',
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
