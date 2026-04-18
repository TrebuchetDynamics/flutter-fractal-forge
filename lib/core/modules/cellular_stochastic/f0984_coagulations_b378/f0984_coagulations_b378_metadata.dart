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
class F0984CoagulationsB378Metadata {
  static const instance = F0984CoagulationsB378Metadata._();
  const F0984CoagulationsB378Metadata._();

  String get id => 'f0984_coagulations_b378';
  String get name => 'Coagulations B378';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B378-S235678',
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
