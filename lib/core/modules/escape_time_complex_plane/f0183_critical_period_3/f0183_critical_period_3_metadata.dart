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
class F0183CriticalPeriod3Metadata {
  static const instance = F0183CriticalPeriod3Metadata._();
  const F0183CriticalPeriod3Metadata._();

  String get id => 'f0183_critical_period_3';
  String get name => 'Critical Period-3';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'c=-0.7545+0.1182i',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Julia set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Julia_set',
    ),
    Citation(
      author: 'Robert Munafo',
      title: 'Mu-Ency: Julia set catalog',
      year: 2023,
      url: 'https://mrob.com/pub/muency/julia.html',
    ),
  ];
}
