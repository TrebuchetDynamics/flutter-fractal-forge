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
class F1026MargolusBlockCaHppGasMetadata {
  static const instance = F1026MargolusBlockCaHppGasMetadata._();
  const F1026MargolusBlockCaHppGasMetadata._();

  String get id => 'f1026_margolus_block_ca_hpp_gas';
  String get name => 'Margolus Block CA (HPP gas)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Hardy, Y. Pomeau, O. de Pazzis',
      title: 'Time evolution of two-dimensional model system. I. Invariant states and time correlation functions',
      year: 1973,
      url: 'https://doi.org/10.1063/1.1666197',
    ),
  ];
}
