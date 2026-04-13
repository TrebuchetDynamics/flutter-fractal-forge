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
class F0284CrystalIfsMetadata {
  static const instance = F0284CrystalIfsMetadata._();
  const F0284CrystalIfsMetadata._();

  String get id => 'f0284_crystal_ifs';
  String get name => 'Crystal IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Crystal IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
