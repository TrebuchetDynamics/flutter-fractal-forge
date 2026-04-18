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
class F0717StampfliDodecagonalMetadata {
  static const instance = F0717StampfliDodecagonalMetadata._();
  const F0717StampfliDodecagonalMetadata._();

  String get id => 'f0717_stampfli_dodecagonal';
  String get name => 'Stampfli Dodecagonal';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Stampfli',
      title: 'A dodecagonal quasiperiodic lattice in two dimensions',
      year: 1986,
      url: 'https://doi.org/10.1016/0378-4371(86)90021-5',
    ),
  ];
}
