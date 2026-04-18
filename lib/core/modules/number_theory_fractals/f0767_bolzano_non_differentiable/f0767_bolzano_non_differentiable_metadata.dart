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
class F0767BolzanoNonDifferentiableMetadata {
  static const instance = F0767BolzanoNonDifferentiableMetadata._();
  const F0767BolzanoNonDifferentiableMetadata._();

  String get id => 'f0767_bolzano_non_differentiable';
  String get name => 'Bolzano Non-Differentiable';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Bolzano function',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Bolzano',
      title: 'Functionenlehre (posthumous)',
      year: 1830,
      url: 'https://mathworld.wolfram.com/BolzanoFunction.html',
    ),
  ];
}
