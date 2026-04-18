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
class F0748Oregonator3VariableMetadata {
  static const instance = F0748Oregonator3VariableMetadata._();
  const F0748Oregonator3VariableMetadata._();

  String get id => 'f0748_oregonator_3_variable';
  String get name => 'Oregonator (3-variable)';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Oregonator',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. J. Field, R. M. Noyes',
      title: 'Oscillations in chemical systems IV: Limit cycle behavior in a model of a real chemical reaction',
      year: 1974,
      url: 'https://doi.org/10.1063/1.1681288',
    ),
  ];
}
