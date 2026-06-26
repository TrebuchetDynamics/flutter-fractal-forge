import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../a11y/shared/main_app_a11y_harness.dart';

/// Viewport configurations to test against.
const _viewports = <String, Size>{
  'medium_phone_375x812': Size(375, 812),
  'large_phone_428x926': Size(428, 926),
  'tablet_768x1024': Size(768, 1024),
};

/// Text scale factors to test.
const _textScales = <double>[1.0, 1.5, 2.0];

void main() {
  group('Layout overflow tests — HomeScreen / Catalog', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    for (final viewport in _viewports.entries) {
      for (final textScale in _textScales) {
        testWidgets(
          'no overflow at ${viewport.key} textScale=$textScale',
          (tester) async {
            try {
              tester.view.physicalSize =
                  viewport.value * tester.view.devicePixelRatio;
              tester.view.devicePixelRatio = tester.view.devicePixelRatio;

              await tester.pumpWidget(
                MediaQuery(
                  data: MediaQueryData(
                    size: viewport.value,
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: harness.buildApp(),
                ),
              );
              await tester.pumpAndSettle();

              final overflowErrors = <String>[];
              Object? exception;
              while ((exception = tester.takeException()) != null) {
                final msg = exception.toString();
                if (msg.contains('overflowed') ||
                    msg.contains('OVERFLOW') ||
                    msg.contains('RenderFlex')) {
                  overflowErrors.add(msg);
                } else {
                  fail('Unexpected Flutter exception: $msg');
                }
              }

              if (overflowErrors.isNotEmpty) {
                // ignore: avoid_print
                print(
                  'OVERFLOW at ${viewport.key} textScale=$textScale:\n'
                  '${overflowErrors.join('\n')}',
                );
              }

              expect(
                overflowErrors,
                isEmpty,
                reason:
                    'Overflow detected at ${viewport.key} textScale=$textScale',
              );
            } finally {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            }
          },
        );
      }
    }
  });
}
