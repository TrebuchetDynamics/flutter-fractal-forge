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
class F1147BuddhabrotD5Metadata {
  static const instance = F1147BuddhabrotD5Metadata._();
  const F1147BuddhabrotD5Metadata._();

  String get id => 'f1147_buddhabrot_d_5';
  String get name => 'Buddhabrot d=5';
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
