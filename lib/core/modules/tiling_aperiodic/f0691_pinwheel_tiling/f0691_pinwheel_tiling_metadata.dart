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
class F0691PinwheelTilingMetadata {
  static const instance = F0691PinwheelTilingMetadata._();
  const F0691PinwheelTilingMetadata._();

  String get id => 'f0691_pinwheel_tiling';
  String get name => 'Pinwheel Tiling';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Conway-Radin pinwheel',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Radin',
      title: 'The pinwheel tilings of the plane',
      year: 1994,
      url: 'https://doi.org/10.2307/2118643',
    ),
  ];
}
