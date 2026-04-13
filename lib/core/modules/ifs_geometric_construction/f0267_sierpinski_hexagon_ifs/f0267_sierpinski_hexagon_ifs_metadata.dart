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
class F0267SierpinskiHexagonIfsMetadata {
  static const instance = F0267SierpinskiHexagonIfsMetadata._();
  const F0267SierpinskiHexagonIfsMetadata._();

  String get id => 'f0267_sierpinski_hexagon_ifs';
  String get name => 'Sierpinski Hexagon IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    '6-gon Sierpinski',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Sierpinski hexagon',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
