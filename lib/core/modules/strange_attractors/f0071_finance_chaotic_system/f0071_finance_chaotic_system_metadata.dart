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
class F0071FinanceChaoticSystemMetadata {
  static const instance = F0071FinanceChaoticSystemMetadata._();
  const F0071FinanceChaoticSystemMetadata._();

  String get id => 'f0071_finance_chaotic_system';
  String get name => 'Finance Chaotic System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Ma, Y. Chen',
      title: 'Bifurcation topology of a financial chaotic system',
      year: 2001,
      url: 'https://doi.org/10.1007/BF02435525',
    ),
  ];
}
