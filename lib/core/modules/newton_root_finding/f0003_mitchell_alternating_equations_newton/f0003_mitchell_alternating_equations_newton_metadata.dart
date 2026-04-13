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
class F0003MitchellAlternatingEquationsNewtonMetadata {
  static const instance = F0003MitchellAlternatingEquationsNewtonMetadata._();
  const F0003MitchellAlternatingEquationsNewtonMetadata._();

  String get id => 'f0003_mitchell_alternating_equations_newton';
  String get name => 'Mitchell Alternating-Equations Newton';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Alternating Newton',
    'Newton with cycling equations',
    'Multi-equation Newton',
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
