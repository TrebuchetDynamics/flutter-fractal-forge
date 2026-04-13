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
class F05983dKochSnowflakeMetadata {
  static const instance = F05983dKochSnowflakeMetadata._();
  const F05983dKochSnowflakeMetadata._();

  String get id => 'f0598_3d_koch_snowflake';
  String get name => '3D Koch Snowflake';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    '3D Koch Snowflake',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: '3D Fractal catalog',
      year: 2010,
      url: 'http://paulbourke.net/fractals/',
    ),
  ];
}
