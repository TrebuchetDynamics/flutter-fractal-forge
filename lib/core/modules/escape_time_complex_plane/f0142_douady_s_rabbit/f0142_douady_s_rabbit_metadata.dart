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
class F0142DouadySRabbitMetadata {
  static const instance = F0142DouadySRabbitMetadata._();
  const F0142DouadySRabbitMetadata._();

  String get id => 'f0142_douady_s_rabbit';
  String get name => 'Douady&#39;s Rabbit';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Rabbit Julia',
    'period-3 rabbit',
    'c=-0.123+0.745i',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Douady, J. H. Hubbard',
      title: 'Étude dynamique des polynômes complexes',
      year: 1984,
      url: 'https://www.math.cornell.edu/~hubbard/OrsayFrench.pdf',
    ),
  ];
}
