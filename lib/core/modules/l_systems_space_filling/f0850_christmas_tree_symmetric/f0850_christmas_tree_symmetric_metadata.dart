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
class F0850ChristmasTreeSymmetricMetadata {
  static const instance = F0850ChristmasTreeSymmetricMetadata._();
  const F0850ChristmasTreeSymmetricMetadata._();

  String get id => 'f0850_christmas_tree_symmetric';
  String get name => 'Christmas Tree Symmetric';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'xmas tree',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}
