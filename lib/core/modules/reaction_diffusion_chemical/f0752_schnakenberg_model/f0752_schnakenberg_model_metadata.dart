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
class F0752SchnakenbergModelMetadata {
  static const instance = F0752SchnakenbergModelMetadata._();
  const F0752SchnakenbergModelMetadata._();

  String get id => 'f0752_schnakenberg_model';
  String get name => 'Schnakenberg Model';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Schnakenberg',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Schnakenberg',
      title: 'Simple chemical reaction systems with limit cycle behaviour',
      year: 1979,
      url: 'https://doi.org/10.1016/0022-5193(79)90042-0',
    ),
  ];
}
