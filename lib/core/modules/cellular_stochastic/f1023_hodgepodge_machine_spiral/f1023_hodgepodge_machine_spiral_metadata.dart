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
class F1023HodgepodgeMachineSpiralMetadata {
  static const instance = F1023HodgepodgeMachineSpiralMetadata._();
  const F1023HodgepodgeMachineSpiralMetadata._();

  String get id => 'f1023_hodgepodge_machine_spiral';
  String get name => 'Hodgepodge Machine (Spiral)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Gerhardt, H. Schuster',
      title: 'A cellular automaton describing the formation of spatially ordered structures in chemical systems',
      year: 1989,
      url: 'https://doi.org/10.1016/0167-2789(89)90147-8',
    ),
  ];
}
