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
class F1003PlowWorldB378S012345678Metadata {
  static const instance = F1003PlowWorldB378S012345678Metadata._();
  const F1003PlowWorldB378S012345678Metadata._();

  String get id => 'f1003_plow_world_b378_s012345678';
  String get name => 'Plow World (B378/S012345678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B378-S012345678',
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
