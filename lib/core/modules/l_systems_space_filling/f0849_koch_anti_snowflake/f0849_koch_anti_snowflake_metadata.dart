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
class F0849KochAntiSnowflakeMetadata {
  static const instance = F0849KochAntiSnowflakeMetadata._();
  const F0849KochAntiSnowflakeMetadata._();

  String get id => 'f0849_koch_anti_snowflake';
  String get name => 'Koch Anti-Snowflake';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Anti-Koch',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
