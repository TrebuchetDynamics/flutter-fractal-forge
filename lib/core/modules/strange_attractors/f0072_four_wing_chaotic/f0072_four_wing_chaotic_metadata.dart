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
class F0072FourWingChaoticMetadata {
  static const instance = F0072FourWingChaoticMetadata._();
  const F0072FourWingChaoticMetadata._();

  String get id => 'f0072_four_wing_chaotic';
  String get name => 'Four-Wing Chaotic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. Wang, Y. Zhang',
      title: 'A new four-wing chaotic attractor with circuit implementation',
      year: 2012,
      url: 'https://doi.org/10.1016/j.chaos.2011.08.006',
    ),
  ];
}
