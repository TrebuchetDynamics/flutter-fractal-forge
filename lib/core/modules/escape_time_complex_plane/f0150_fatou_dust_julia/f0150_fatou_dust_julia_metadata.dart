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
class F0150FatouDustJuliaMetadata {
  static const instance = F0150FatouDustJuliaMetadata._();
  const F0150FatouDustJuliaMetadata._();

  String get id => 'f0150_fatou_dust_julia';
  String get name => 'Fatou Dust Julia';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Fatou dust',
    'Cantor dust Julia',
    'c=0.4+0.4i',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia',
      title: 'Julia set',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Julia_set',
    ),
    Citation(
      author: 'Robert Munafo',
      title: 'Mu-Ency: Julia set catalog',
      year: 2023,
      url: 'https://mrob.com/pub/muency/julia.html',
    ),
  ];
}
