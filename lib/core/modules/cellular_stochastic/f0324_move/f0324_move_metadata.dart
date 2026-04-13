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
class F0324MoveMetadata {
  static const instance = F0324MoveMetadata._();
  const F0324MoveMetadata._();

  String get id => 'f0324_move';
  String get name => 'Move';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B368/S245',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Alan Hensel',
      title: 'Move CA',
      year: 1998,
      url: 'https://www.conwaylife.com/wiki/OCA:Move',
    ),
  ];
}
