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
class F0277TwinChristmasTreeMetadata {
  static const instance = F0277TwinChristmasTreeMetadata._();
  const F0277TwinChristmasTreeMetadata._();

  String get id => 'f0277_twin_christmas_tree';
  String get name => 'Twin Christmas Tree';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Twin Christmas tree',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
