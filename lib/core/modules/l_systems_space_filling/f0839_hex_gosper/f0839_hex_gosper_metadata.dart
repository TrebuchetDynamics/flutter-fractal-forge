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
class F0839HexGosperMetadata {
  static const instance = F0839HexGosperMetadata._();
  const F0839HexGosperMetadata._();

  String get id => 'f0839_hex_gosper';
  String get name => 'Hex-Gosper';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'hexagonal Gosper',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Hex-Gosper',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
