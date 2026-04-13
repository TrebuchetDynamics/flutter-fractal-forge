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
class F0326ServiettesMetadata {
  static const instance = F0326ServiettesMetadata._();
  const F0326ServiettesMetadata._();

  String get id => 'f0326_serviettes';
  String get name => 'Serviettes';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B234/S_',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Serviettes CA',
      year: 1999,
      url: 'https://www.conwaylife.com/wiki/OCA:Serviettes',
    ),
  ];
}
