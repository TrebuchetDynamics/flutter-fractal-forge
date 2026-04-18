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
class F1006SlowStainsB36S378Metadata {
  static const instance = F1006SlowStainsB36S378Metadata._();
  const F1006SlowStainsB36S378Metadata._();

  String get id => 'f1006_slow_stains_b36_s378';
  String get name => 'Slow Stains (B36/S378)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B36-S378',
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
