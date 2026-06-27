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
      final proguardRules =
          File('android/app/proguard-rules.pro').readAsStringSync();

      expect(mainActivity, contains('WindowCompat.setDecorFitsSystemWindows'));
      expect(mainActivity, contains('WindowInsetsControllerCompat'));
      expect(
          mainActivity, isNot(contains('androidx.activity.enableEdgeToEdge')));
      expect(mainActivity, isNot(contains('.setStatusBarColor(')));
      expect(mainActivity, isNot(contains('.setNavigationBarColor(')));
      expect(mainActivity,
          isNot(contains('LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES')));
      expect(
        android15Styles,
        isNot(contains('windowOptOutEdgeToEdgeEnforcement')),
      );
      expect(
        android15Styles,
        contains('android:windowLayoutInDisplayCutoutMode">always'),
      );
      expect(buildGradle, contains('targetSdk = 36'));
      expect(buildGradle, isNot(contains('androidx.activity:activity')));
      expect(dartMain, isNot(contains('SystemChrome.setSystemUIOverlayStyle')));
      expect(proguardRules, contains('setStatusBarColor'));
      expect(proguardRules, contains('setNavigationBarColor'));
    },
  );
}
