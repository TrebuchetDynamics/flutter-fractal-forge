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
class F0810BernoulliShiftMetadata {
  static const instance = F0810BernoulliShiftMetadata._();
  const F0810BernoulliShiftMetadata._();

  String get id => 'f0810_bernoulli_shift';
  String get name => 'Bernoulli Shift';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. D. Birkhoff',
      title: 'Dynamical Systems',
      year: 1927,
      url: 'https://en.wikipedia.org/wiki/Bernoulli_scheme',
    ),
  ];
}
