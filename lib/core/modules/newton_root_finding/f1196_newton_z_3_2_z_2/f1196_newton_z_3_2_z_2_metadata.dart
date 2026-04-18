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
class F1196NewtonZ32Z2Metadata {
  static const instance = F1196NewtonZ32Z2Metadata._();
  const F1196NewtonZ32Z2Metadata._();

  String get id => 'f1196_newton_z_3_2_z_2';
  String get name => 'Newton z^3 - 2*z + 2';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Smale Newton trap',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Complex_dynamics',
    ),
  ];
}
