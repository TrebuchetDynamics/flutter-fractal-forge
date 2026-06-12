import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android edge-to-edge is configured natively without Flutter system bar color APIs', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/fractals/flutter_fractals/MainActivity.kt',
    ).readAsStringSync();
    final dartMain = File('lib/main.dart').readAsStringSync();

    expect(mainActivity, contains('import androidx.activity.enableEdgeToEdge'));
    expect(mainActivity, contains('enableEdgeToEdge('));
    expect(mainActivity, contains('SystemBarStyle.dark(Color.TRANSPARENT)'));
    expect(dartMain, isNot(contains('SystemChrome.setSystemUIOverlayStyle')));
  });
}
