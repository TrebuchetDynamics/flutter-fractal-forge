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
class F1153BuddhabrotTricornMetadata {
  static const instance = F1153BuddhabrotTricornMetadata._();
  const F1153BuddhabrotTricornMetadata._();

  String get id => 'f1153_buddhabrot_tricorn';
  String get name => 'Buddhabrot Tricorn';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'tricorn';

  List<String> get aliases => const [
    'Tricorn Buddhabrot',
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
