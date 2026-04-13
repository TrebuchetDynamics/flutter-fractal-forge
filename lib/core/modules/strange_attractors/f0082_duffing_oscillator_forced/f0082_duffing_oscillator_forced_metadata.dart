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
class F0082DuffingOscillatorForcedMetadata {
  static const instance = F0082DuffingOscillatorForcedMetadata._();
  const F0082DuffingOscillatorForcedMetadata._();

  String get id => 'f0082_duffing_oscillator_forced';
  String get name => 'Duffing Oscillator (forced)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Duffing',
      title: 'Erzwungene Schwingungen bei veränderlicher Eigenfrequenz',
      year: 1918,
      url: 'https://archive.org/details/erzwungeneschwin00duff',
    ),
  ];
}
