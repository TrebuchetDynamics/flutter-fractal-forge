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
class F0002MitchellRotatingCNewtonMetadata {
  static const instance = F0002MitchellRotatingCNewtonMetadata._();
  const F0002MitchellRotatingCNewtonMetadata._();

  String get id => 'f0002_mitchell_rotating_c_newton';
  String get name => 'Mitchell Rotating-C Newton';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Rotating Newton',
    'Newton with rotating constant',
    'Time-varying Newton',
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
