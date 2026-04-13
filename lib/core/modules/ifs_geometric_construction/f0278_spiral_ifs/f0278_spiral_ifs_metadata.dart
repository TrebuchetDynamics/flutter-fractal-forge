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
class F0278SpiralIfsMetadata {
  static const instance = F0278SpiralIfsMetadata._();
  const F0278SpiralIfsMetadata._();

  String get id => 'f0278_spiral_ifs';
  String get name => 'Spiral IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'logarithmic spiral IFS',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Spiral IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
