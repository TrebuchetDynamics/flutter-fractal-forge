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
class F0848KochSnowflakeOrder2Metadata {
  static const instance = F0848KochSnowflakeOrder2Metadata._();
  const F0848KochSnowflakeOrder2Metadata._();

  String get id => 'f0848_koch_snowflake_order_2';
  String get name => 'Koch Snowflake (Order 2)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Koch snowflake',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
