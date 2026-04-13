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
class F0006HalleySMethodMetadata {
  static const instance = F0006HalleySMethodMetadata._();
  const F0006HalleySMethodMetadata._();

  String get id => 'f0006_halley_s_method';
  String get name => 'Halley&#39;s Method';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Halley',
    'Halley&#39;s cubic method',
    'Tangent hyperbolas method',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Edmond Halley',
      title: 'Methodus nova, accurata, et facilis inveniendi radices',
      year: 1694,
      url: 'https://mathworld.wolfram.com/HalleysMethod.html',
    ),
  ];
}
