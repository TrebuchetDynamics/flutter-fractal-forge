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
class F1142BuddhabrotMetadata {
  static const instance = F1142BuddhabrotMetadata._();
  const F1142BuddhabrotMetadata._();

  String get id => 'f1142_buddhabrot';
  String get name => 'Buddhabrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Buddhabrot',
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
