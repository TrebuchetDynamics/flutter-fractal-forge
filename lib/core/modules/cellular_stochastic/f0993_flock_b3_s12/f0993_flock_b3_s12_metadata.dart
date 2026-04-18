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
class F0993FlockB3S12Metadata {
  static const instance = F0993FlockB3S12Metadata._();
  const F0993FlockB3S12Metadata._();

  String get id => 'f0993_flock_b3_s12';
  String get name => 'Flock (B3/S12)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3-S12',
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
