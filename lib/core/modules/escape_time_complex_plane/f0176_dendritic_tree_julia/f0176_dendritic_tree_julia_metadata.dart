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
class F0176DendriticTreeJuliaMetadata {
  static const instance = F0176DendriticTreeJuliaMetadata._();
  const F0176DendriticTreeJuliaMetadata._();

  String get id => 'f0176_dendritic_tree_julia';
  String get name => 'Dendritic Tree Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'dendritic tree',
    'c=-0.8+0.2i',
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
