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
class F0013PolynomiographyBasicFamilyIterationMetadata {
  static const instance = F0013PolynomiographyBasicFamilyIterationMetadata._();
  const F0013PolynomiographyBasicFamilyIterationMetadata._();

  String get id => 'f0013_polynomiography_basic_family_iteration';
  String get name => 'Polynomiography (Basic Family Iteration)';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Polynomiography',
    'Kalantari B_m iteration',
    'Basic family',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Bahman Kalantari',
      title: 'Polynomial Root-Finding and Polynomiography',
      year: 2009,
      url: 'https://en.wikipedia.org/wiki/Polynomiography',
    ),
  ];
}
