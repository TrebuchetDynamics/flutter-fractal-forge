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
class F0009HouseholderSMethod3rdOrderMetadata {
  static const instance = F0009HouseholderSMethod3rdOrderMetadata._();
  const F0009HouseholderSMethod3rdOrderMetadata._();

  String get id => 'f0009_householder_s_method_3rd_order';
  String get name => 'Householder&#39;s Method (3rd Order)';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Householder',
    'Householder-3',
    'H3 method',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Alston Scott Householder',
      title: 'The Numerical Treatment of a Single Nonlinear Equation',
      year: 1970,
      url: 'https://en.wikipedia.org/wiki/Householder%27s_method',
    ),
  ];
}
