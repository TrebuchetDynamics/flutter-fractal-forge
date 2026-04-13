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
class F0268SierpinskiHeptagonIfsMetadata {
  static const instance = F0268SierpinskiHeptagonIfsMetadata._();
  const F0268SierpinskiHeptagonIfsMetadata._();

  String get id => 'f0268_sierpinski_heptagon_ifs';
  String get name => 'Sierpinski Heptagon IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    '7-gon Sierpinski',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Sierpinski heptagon',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
