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
class F0991DiamoebaB35678S5678Metadata {
  static const instance = F0991DiamoebaB35678S5678Metadata._();
  const F0991DiamoebaB35678S5678Metadata._();

  String get id => 'f0991_diamoeba_b35678_s5678';
  String get name => 'Diamoeba (B35678/S5678)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B35678-S5678',
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
