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
class F0170FeigenbaumPointMetadata {
  static const instance = F0170FeigenbaumPointMetadata._();
  const F0170FeigenbaumPointMetadata._();

  String get id => 'f0170_feigenbaum_point';
  String get name => 'Feigenbaum Point';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Feigenbaum',
    'c=-1.401155+0.0i',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Julia set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Julia_set',
    ),
    Citation(
      author: 'Robert Munafo',
      title: 'Mu-Ency: Julia set catalog',
      year: 2023,
      url: 'https://mrob.com/pub/muency/julia.html',
    ),
  ];
}
