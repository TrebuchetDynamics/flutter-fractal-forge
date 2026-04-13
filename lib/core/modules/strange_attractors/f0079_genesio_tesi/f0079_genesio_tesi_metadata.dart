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
class F0079GenesioTesiMetadata {
  static const instance = F0079GenesioTesiMetadata._();
  const F0079GenesioTesiMetadata._();

  String get id => 'f0079_genesio_tesi';
  String get name => 'Genesio-Tesi';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Genesio, A. Tesi',
      title: 'Harmonic balance methods for chaotic dynamics',
      year: 1992,
      url: 'https://doi.org/10.1016/0005-1098(92)90177-H',
    ),
  ];
}
