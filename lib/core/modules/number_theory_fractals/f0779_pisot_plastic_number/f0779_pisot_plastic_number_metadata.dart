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
class F0779PisotPlasticNumberMetadata {
  static const instance = F0779PisotPlasticNumberMetadata._();
  const F0779PisotPlasticNumberMetadata._();

  String get id => 'f0779_pisot_plastic_number';
  String get name => 'Pisot Plastic Number';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Plastic number',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. van der Laan',
      title: 'The plastic number',
      year: 1928,
      url: 'https://mathworld.wolfram.com/PlasticNumber.html',
    ),
  ];
}
