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
class F1146BuddhabrotD4Metadata {
  static const instance = F1146BuddhabrotD4Metadata._();
  const F1146BuddhabrotD4Metadata._();

  String get id => 'f1146_buddhabrot_d_4';
  String get name => 'Buddhabrot d=4';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_quartic';

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
