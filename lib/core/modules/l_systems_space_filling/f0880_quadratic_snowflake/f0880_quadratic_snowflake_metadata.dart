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
class F0880QuadraticSnowflakeMetadata {
  static const instance = F0880QuadraticSnowflakeMetadata._();
  const F0880QuadraticSnowflakeMetadata._();

  String get id => 'f0880_quadratic_snowflake';
  String get name => 'Quadratic Snowflake';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Quadratic snowflake',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
