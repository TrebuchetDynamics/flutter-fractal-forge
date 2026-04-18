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
class F1149BuddhabrotD7Metadata {
  static const instance = F1149BuddhabrotD7Metadata._();
  const F1149BuddhabrotD7Metadata._();

  String get id => 'f1149_buddhabrot_d_7';
  String get name => 'Buddhabrot d=7';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
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
