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
class F0996WalledCitiesB45678S2345Metadata {
  static const instance = F0996WalledCitiesB45678S2345Metadata._();
  const F0996WalledCitiesB45678S2345Metadata._();

  String get id => 'f0996_walled_cities_b45678_s2345';
  String get name => 'Walled Cities (B45678/S2345)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B45678-S2345',
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
