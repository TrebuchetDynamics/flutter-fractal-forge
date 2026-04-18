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
class F1007HighflockB36S12Metadata {
  static const instance = F1007HighflockB36S12Metadata._();
  const F1007HighflockB36S12Metadata._();

  String get id => 'f1007_highflock_b36_s12';
  String get name => 'HighFlock (B36/S12)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B36-S12',
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
