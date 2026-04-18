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
class F0877ProuhetThueMorseCurveLSystemMetadata {
  static const instance = F0877ProuhetThueMorseCurveLSystemMetadata._();
  const F0877ProuhetThueMorseCurveLSystemMetadata._();

  String get id => 'f0877_prouhet_thue_morse_curve_l_system';
  String get name => 'Prouhet-Thue-Morse Curve L-system';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
    'PTM curve',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Allouche, J. Shallit',
      title: 'Automatic Sequences',
      year: 2003,
      url: 'https://doi.org/10.1017/CBO9780511546563',
    ),
  ];
}
