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
class F0273KochSnowflakeIfsMetadata {
  static const instance = F0273KochSnowflakeIfsMetadata._();
  const F0273KochSnowflakeIfsMetadata._();

  String get id => 'f0273_koch_snowflake_ifs';
  String get name => 'Koch Snowflake IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Koch snowflake IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
