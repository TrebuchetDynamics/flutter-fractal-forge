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
class F1231DouadyHubbardRabbitRationalMetadata {
  static const instance = F1231DouadyHubbardRabbitRationalMetadata._();
  const F1231DouadyHubbardRabbitRationalMetadata._();

  String get id => 'f1231_douady_hubbard_rabbit_rational';
  String get name => 'Douady-Hubbard Rabbit (Rational)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'rabbit Julia',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Douady, J. H. Hubbard',
      title: 'Étude dynamique des polynômes complexes',
      year: 1985,
      url: 'https://en.wikipedia.org/wiki/Julia_set#Examples',
    ),
  ];
}
