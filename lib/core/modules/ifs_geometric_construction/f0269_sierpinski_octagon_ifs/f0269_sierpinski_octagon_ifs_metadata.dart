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
class F0269SierpinskiOctagonIfsMetadata {
  static const instance = F0269SierpinskiOctagonIfsMetadata._();
  const F0269SierpinskiOctagonIfsMetadata._();

  String get id => 'f0269_sierpinski_octagon_ifs';
  String get name => 'Sierpinski Octagon IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    '8-gon Sierpinski',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Sierpinski octagon',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
