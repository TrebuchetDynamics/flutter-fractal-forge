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
class F0819ArnoldTonguesBifurcationMetadata {
  static const instance = F0819ArnoldTonguesBifurcationMetadata._();
  const F0819ArnoldTonguesBifurcationMetadata._();

  String get id => 'f0819_arnold_tongues_bifurcation';
  String get name => 'Arnold Tongues Bifurcation';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. I. Arnold',
      title: 'Small denominators I: mappings of the circumference into itself',
      year: 1961,
      url: 'https://en.wikipedia.org/wiki/Arnold_tongue',
    ),
  ];
}
