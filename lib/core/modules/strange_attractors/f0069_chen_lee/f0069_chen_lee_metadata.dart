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
class F0069ChenLeeMetadata {
  static const instance = F0069ChenLeeMetadata._();
  const F0069ChenLeeMetadata._();

  String get id => 'f0069_chen_lee';
  String get name => 'Chen-Lee';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'H. Chen, C. Lee',
      title: 'Anti-control of chaos in rigid body motion',
      year: 2004,
      url: 'https://doi.org/10.1016/j.chaos.2004.02.008',
    ),
  ];
}
