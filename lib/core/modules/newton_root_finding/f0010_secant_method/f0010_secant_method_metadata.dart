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
class F0010SecantMethodMetadata {
  static const instance = F0010SecantMethodMetadata._();
  const F0010SecantMethodMetadata._();

  String get id => 'f0010_secant_method';
  String get name => 'Secant Method';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Secant',
    'Two-point method',
    'Discrete Newton',
  ];

  List<Citation> get references => const [
    Citation(
      title: 'Secant method (Wikipedia)',
      url: 'https://en.wikipedia.org/wiki/Secant_method',
    ),
  ];
}
