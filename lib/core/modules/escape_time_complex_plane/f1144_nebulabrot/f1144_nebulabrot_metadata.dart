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
class F1144NebulabrotMetadata {
  static const instance = F1144NebulabrotMetadata._();
  const F1144NebulabrotMetadata._();

  String get id => 'f1144_nebulabrot';
  String get name => 'Nebulabrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Nebulabrot RGB',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Lori Gardi (Melinda Green\'s adaptation)',
      title: 'The Buddhabrot Technique',
      year: 1993,
      url: 'http://superliminal.com/fractals/bbrot/bbrot.htm',
    ),
  ];
}
