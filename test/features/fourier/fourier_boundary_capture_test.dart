import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_boundary_capture.dart';
import 'package:flutter_test/flutter_test.dart';

// Only the external capture future is controlled; layout, paint scheduling,
// capture ownership and image disposal use the real implementation.
class _ControlledCaptureBoundary extends RenderRepaintBoundary {
  final capture = Completer<ui.Image>();
  int captureCount = 0;
  double? requestedPixelRatio;

  @override
  Future<ui.Image> toImage({double pixelRatio = 1.0}) {
    captureCount++;
    requestedPixelRatio = pixelRatio;
    return capture.future;
  }
}

class _BoundaryWidget extends SingleChildRenderObjectWidget {
  const _BoundaryWidget({required super.key, required this.boundary})
      : super(child: const SizedBox(width: 32, height: 32));

  final _ControlledCaptureBoundary boundary;

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) => boundary;
}

void main() {
  late Map<ui.Image, int> disposals;
  late void Function(ui.Image)? previousOnDispose;

  setUp(() {
    disposals = <ui.Image, int>{};
    previousOnDispose = ui.Image.onDispose;
    ui.Image.onDispose = (image) {
      if (disposals.containsKey(image)) {
        disposals[image] = disposals[image]! + 1;
      }
      previousOnDispose?.call(image);
    };
  });

  tearDown(() {
    for (final image in disposals.keys) {
      if (disposals[image] == 0) image.dispose();
    }
    ui.Image.onDispose = previousOnDispose;
  });

  ui.Image trackedImage() {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xff123456), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(1, 1);
    picture.dispose();
    disposals[image] = 0;
    return image;
  }

  Future<GlobalKey> mountBoundary(
    WidgetTester tester,
    _ControlledCaptureBoundary boundary,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Center(child: _BoundaryWidget(key: key, boundary: boundary)),
    );
    return key;
  }

  testWidgets('timeout disposes a late image once without consumer delivery',
      (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    var deliveries = 0;
    Object? failure;
    final completed = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => true,
    ).then<void>((image) {
      deliveries++;
      image?.dispose();
    }, onError: (Object error) {
      failure = error;
    });
    await tester.pump();
    expect(boundary.captureCount, 1);
    await tester.pump(const Duration(seconds: 2));
    await completed;
    expect(failure, isA<TimeoutException>());

    final image = trackedImage();
    boundary.capture.complete(image);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(deliveries, 0,
        reason: 'expired pixels cannot reach the FFT consumer');
    expect(disposals[image], 1);
  });

  testWidgets('timeout skips an already queued dirty-boundary retry',
      (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => boundary.markNeedsPaint());
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => true,
    );
    final failed = expectLater(result, throwsA(isA<TimeoutException>()));
    await tester.pump();
    expect(boundary.captureCount, 0);
    // The deadline expires before the queued retry's next post-frame callback.
    await tester.pump(const Duration(seconds: 2));
    await failed;
    final image = trackedImage();
    boundary.capture.complete(image);
    await tester.pump();
    expect(boundary.captureCount, 0);
  });

  testWidgets('timely image ownership transfers to the caller', (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.5,
      isCurrentCapture: () => true,
    );
    await tester.pump();
    final image = trackedImage();
    boundary.capture.complete(image);
    await tester.pump();
    expect(await result, same(image));
    expect(boundary.requestedPixelRatio, 0.5);
    expect(disposals[image], 0);
    await tester.pump(const Duration(seconds: 3));
    expect(disposals[image], 0);
    image.dispose();
    expect(disposals[image], 1);
  });

  testWidgets('late capture error after timeout is handled', (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => true,
    );
    final failed = expectLater(result, throwsA(isA<TimeoutException>()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await failed;
    boundary.capture.completeError(StateError('late native capture failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalidation skips a queued dirty-boundary retry',
      (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    var current = true;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => boundary.markNeedsPaint());
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => current,
    );
    await tester.pump();
    current = false;
    await tester.pump();
    expect(await result, isNull);
    expect(boundary.captureCount, 0);
  });

  testWidgets('removed boundary returns no image without starting capture',
      (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => true,
    );
    await tester.pumpWidget(const SizedBox());
    expect(await result, isNull);
    expect(boundary.captureCount, 0);
  });

  testWidgets('dirty boundary gets four retries then reports failure',
      (tester) async {
    final boundary = _ControlledCaptureBoundary();
    final key = await mountBoundary(tester, boundary);
    var dirtyFrames = 0;
    void dirtyBeforeCapture(Duration _) {
      boundary.markNeedsPaint();
      if (++dirtyFrames < 5) {
        WidgetsBinding.instance.addPostFrameCallback(dirtyBeforeCapture);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(dirtyBeforeCapture);
    final result = captureFourierBoundaryAfterPaint(
      boundaryKey: key,
      pixelRatio: 0.25,
      isCurrentCapture: () => true,
    );
    var finished = false;
    final failed = expectLater(result, throwsA(isA<StateError>())).then((_) {
      finished = true;
    });
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump();
      expect(finished, isFalse);
    }
    await tester.pump();
    await failed;
    expect(boundary.captureCount, 0);
  });
}
