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
class F0004MitchellRealSystemsNewtonMetadata {
  static const instance = F0004MitchellRealSystemsNewtonMetadata._();
  const F0004MitchellRealSystemsNewtonMetadata._();

  String get id => 'f0004_mitchell_real_systems_newton';
  String get name => 'Mitchell Real-Systems Newton';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Real-component Newton',
    'Split Newton',
    'Decoupled Newton',
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
