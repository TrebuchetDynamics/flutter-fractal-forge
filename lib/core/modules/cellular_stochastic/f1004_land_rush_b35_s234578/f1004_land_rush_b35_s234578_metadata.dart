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
class F1004LandRushB35S234578Metadata {
  static const instance = F1004LandRushB35S234578Metadata._();
  const F1004LandRushB35S234578Metadata._();

  String get id => 'f1004_land_rush_b35_s234578';
  String get name => 'Land Rush (B35/S234578)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B35-S234578',
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
