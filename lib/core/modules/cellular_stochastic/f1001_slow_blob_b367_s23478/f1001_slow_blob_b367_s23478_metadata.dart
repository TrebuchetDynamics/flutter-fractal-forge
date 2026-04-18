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
class F1001SlowBlobB367S23478Metadata {
  static const instance = F1001SlowBlobB367S23478Metadata._();
  const F1001SlowBlobB367S23478Metadata._();

  String get id => 'f1001_slow_blob_b367_s23478';
  String get name => 'Slow Blob (B367/S23478)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B367-S23478',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}
