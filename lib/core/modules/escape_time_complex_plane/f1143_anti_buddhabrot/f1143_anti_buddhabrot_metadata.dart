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
class F1143AntiBuddhabrotMetadata {
  static const instance = F1143AntiBuddhabrotMetadata._();
  const F1143AntiBuddhabrotMetadata._();

  String get id => 'f1143_anti_buddhabrot';
  String get name => 'Anti-Buddhabrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Anti-Buddhabrot',
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
