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
class F1013InverseLifeB0123478S34678Metadata {
  static const instance = F1013InverseLifeB0123478S34678Metadata._();
  const F1013InverseLifeB0123478S34678Metadata._();

  String get id => 'f1013_inverse_life_b0123478_s34678';
  String get name => 'Inverse Life (B0123478/S34678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B0123478-S34678',
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
