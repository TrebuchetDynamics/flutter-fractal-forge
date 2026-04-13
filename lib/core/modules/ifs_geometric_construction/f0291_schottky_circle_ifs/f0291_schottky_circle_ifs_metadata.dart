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
class F0291SchottkyCircleIfsMetadata {
  static const instance = F0291SchottkyCircleIfsMetadata._();
  const F0291SchottkyCircleIfsMetadata._();

  String get id => 'f0291_schottky_circle_ifs';
  String get name => 'Schottky Circle IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Mumford, C. Series, D. Wright',
      title: 'Indra&#39;s Pearls: The Vision of Felix Klein',
      year: 2002,
      url: 'https://doi.org/10.1017/CBO9781107050051',
    ),
  ];
}
