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
class F0053ChenAttractorMetadata {
  static const instance = F0053ChenAttractorMetadata._();
  const F0053ChenAttractorMetadata._();

  String get id => 'f0053_chen_attractor';
  String get name => 'Chen Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Chen, T. Ueta',
      title: 'Yet another chaotic attractor',
      year: 1999,
      url: 'https://doi.org/10.1142/S0218127499001024',
    ),
  ];
}
