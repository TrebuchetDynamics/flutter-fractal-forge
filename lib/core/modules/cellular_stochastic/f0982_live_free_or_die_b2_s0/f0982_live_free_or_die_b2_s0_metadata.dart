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
class F0982LiveFreeOrDieB2S0Metadata {
  static const instance = F0982LiveFreeOrDieB2S0Metadata._();
  const F0982LiveFreeOrDieB2S0Metadata._();

  String get id => 'f0982_live_free_or_die_b2_s0';
  String get name => 'Live Free or Die (B2/S0)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B2-S0',
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
