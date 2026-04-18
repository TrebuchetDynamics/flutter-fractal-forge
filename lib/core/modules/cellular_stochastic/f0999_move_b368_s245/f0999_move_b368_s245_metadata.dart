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
class F0999MoveB368S245Metadata {
  static const instance = F0999MoveB368S245Metadata._();
  const F0999MoveB368S245Metadata._();

  String get id => 'f0999_move_b368_s245';
  String get name => 'Move (B368/S245)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B368-S245',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}
