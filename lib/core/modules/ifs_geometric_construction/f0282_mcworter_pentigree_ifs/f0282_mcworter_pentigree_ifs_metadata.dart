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
class F0282McworterPentigreeIfsMetadata {
  static const instance = F0282McworterPentigreeIfsMetadata._();
  const F0282McworterPentigreeIfsMetadata._();

  String get id => 'f0282_mcworter_pentigree_ifs';
  String get name => 'McWorter Pentigree IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Pentigree IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}
