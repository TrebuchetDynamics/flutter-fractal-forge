import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android edge-to-edge is configured natively without Flutter system bar color APIs',
    () {
      final mainActivity = File(
        'android/app/src/main/kotlin/com/fractals/flutter_fractals/MainActivity.kt',
      ).readAsStringSync();
      final dartMain = File('lib/main.dart').readAsStringSync();
      final android15Styles = File(
        'android/app/src/main/res/values-v35/styles.xml',
      ).readAsStringSync();
      final buildGradle =
          File('android/app/build.gradle.kts').readAsStringSync();

      expect(
          mainActivity, contains('import androidx.activity.enableEdgeToEdge'));
      expect(mainActivity, contains('enableEdgeToEdge('));
      expect(
        mainActivity,
        contains('SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT)'),
      );
      expect(mainActivity, isNot(contains('SystemBarStyle.dark(Color.argb')));
      expect(
        android15Styles,
        isNot(contains('windowOptOutEdgeToEdgeEnforcement')),
      );
      expect(
        android15Styles,
        contains('android:windowLayoutInDisplayCutoutMode">shortEdges'),
      );
      expect(buildGradle, contains('targetSdk = 36'));
      expect(dartMain, isNot(contains('SystemChrome.setSystemUIOverlayStyle')));
    },
  );
}
