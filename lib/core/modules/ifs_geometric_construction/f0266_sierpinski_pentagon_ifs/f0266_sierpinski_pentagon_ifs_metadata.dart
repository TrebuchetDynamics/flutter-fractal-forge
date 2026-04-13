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
class F0266SierpinskiPentagonIfsMetadata {
  static const instance = F0266SierpinskiPentagonIfsMetadata._();
  const F0266SierpinskiPentagonIfsMetadata._();

  String get id => 'f0266_sierpinski_pentagon_ifs';
  String get name => 'Sierpinski Pentagon IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    '5-gon Sierpinski',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Sierpinski polygon IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
