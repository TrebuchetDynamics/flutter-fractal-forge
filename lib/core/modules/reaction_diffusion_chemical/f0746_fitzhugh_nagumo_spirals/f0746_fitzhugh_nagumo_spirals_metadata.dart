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
class F0746FitzhughNagumoSpiralsMetadata {
  static const instance = F0746FitzhughNagumoSpiralsMetadata._();
  const F0746FitzhughNagumoSpiralsMetadata._();

  String get id => 'f0746_fitzhugh_nagumo_spirals';
  String get name => 'FitzHugh-Nagumo Spirals';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. FitzHugh',
      title: 'Impulses and physiological states in theoretical models of nerve membrane',
      year: 1961,
      url: 'https://doi.org/10.1016/S0006-3495(61)86902-6',
    ),
  ];
}
