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
class F1181TriangleInequalityAverageMetadata {
  static const instance = F1181TriangleInequalityAverageMetadata._();
  const F1181TriangleInequalityAverageMetadata._();

  String get id => 'f1181_triangle_inequality_average';
  String get name => 'Triangle Inequality Average';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Mitchell',
      title: 'The triangle inequality average colouring method',
      year: 1999,
      url: 'https://www.fractalus.com/kerry/articles/tia/tia.html',
    ),
  ];
}
