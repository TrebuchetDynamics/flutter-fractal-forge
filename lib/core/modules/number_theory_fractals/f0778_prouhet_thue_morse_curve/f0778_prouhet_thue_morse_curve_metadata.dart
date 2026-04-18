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
class F0778ProuhetThueMorseCurveMetadata {
  static const instance = F0778ProuhetThueMorseCurveMetadata._();
  const F0778ProuhetThueMorseCurveMetadata._();

  String get id => 'f0778_prouhet_thue_morse_curve';
  String get name => 'Prouhet-Thue-Morse Curve';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Allouche, J. Shallit',
      title: 'Automatic sequences: theory, applications, generalizations',
      year: 2003,
      url: 'https://doi.org/10.1017/CBO9780511546563',
    ),
  ];
}
