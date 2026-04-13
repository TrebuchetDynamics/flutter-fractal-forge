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
class F0333HodgepodgeMachineMetadata {
  static const instance = F0333HodgepodgeMachineMetadata._();
  const F0333HodgepodgeMachineMetadata._();

  String get id => 'f0333_hodgepodge_machine';
  String get name => 'Hodgepodge Machine';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Gerhardt, H. Schuster, J. J. Tyson',
      title: 'A cellular automaton model of excitable media including curvature',
      year: 1990,
      url: 'https://doi.org/10.1016/0167-2789(90)90136-E',
    ),
  ];
}
