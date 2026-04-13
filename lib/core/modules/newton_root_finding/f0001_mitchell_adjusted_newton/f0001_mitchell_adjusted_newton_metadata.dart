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
class F0001MitchellAdjustedNewtonMetadata {
  static const instance = F0001MitchellAdjustedNewtonMetadata._();
  const F0001MitchellAdjustedNewtonMetadata._();

  String get id => 'f0001_mitchell_adjusted_newton';
  String get name => 'Mitchell Adjusted Newton';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Adjusted Newton',
    'Alpha Newton',
    'Newton with adjustment factor',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Kerry Mitchell',
      title: 'Fun with Newton&#39;s Method',
      year: 2019,
      url: 'https://archive.bridgesmathart.org/2019/bridges2019-271.html',
    ),
  ];
}
