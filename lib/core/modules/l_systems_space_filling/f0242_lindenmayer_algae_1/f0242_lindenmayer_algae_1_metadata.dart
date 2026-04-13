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
class F0242LindenmayerAlgae1Metadata {
  static const instance = F0242LindenmayerAlgae1Metadata._();
  const F0242LindenmayerAlgae1Metadata._();

  String get id => 'f0242_lindenmayer_algae_1';
  String get name => 'Lindenmayer Algae 1';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Algae',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Lindenmayer Algae 1',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}
