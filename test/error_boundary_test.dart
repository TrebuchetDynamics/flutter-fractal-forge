import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/widgets/error_boundary.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';

void main() {
  setUpAll(() {
    // Initialize crash reporter for tests
    CrashReporter.install(maxEvents: 10);
  });

  tearDown(() {
    // Clear recorded events after each test
    CrashReporter.instance.clear();
  });

  group('ErrorBoundary', () {
    testWidgets('renders child when no error occurs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('accepts custom config', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBoundary(
              config: const ErrorBoundaryConfig(
                title: 'Test Error',
                message: 'Something went wrong in the test',
                showRetry: true,
              ),
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);
    });
  });

  group('ErrorBoundaryConfig', () {
    test('has correct defaults', () {
      const config = ErrorBoundaryConfig();

      expect(config.showRetry, isTrue);
      expect(config.showDetails, isTrue);
      expect(config.severity, ErrorSeverity.error);
      expect(config.title, isNull);
      expect(config.message, isNull);
      expect(config.icon, isNull);
      expect(config.actions, isNull);
    });

    test('shader config has correct values', () {
      const config = ErrorBoundaryConfig.shader;

      expect(config.title, 'Shader Error');
      expect(config.showRetry, isTrue);
      expect(config.severity, ErrorSeverity.error);
      expect(config.icon, Icons.memory_rounded);
    });

    test('network config has correct values', () {
      const config = ErrorBoundaryConfig.network;

      expect(config.title, 'Connection Error');
      expect(config.showRetry, isTrue);
      expect(config.showDetails, isFalse);
      expect(config.severity, ErrorSeverity.warning);
      expect(config.icon, Icons.wifi_off_rounded);
    });

    test('critical config has correct values', () {
      const config = ErrorBoundaryConfig.critical;

      expect(config.title, 'Something Went Wrong');
      expect(config.showRetry, isFalse);
      expect(config.showDetails, isTrue);
      expect(config.severity, ErrorSeverity.critical);
      expect(config.icon, Icons.error_outline_rounded);
    });
  });

  group('ErrorAction', () {
    test('creates action with required parameters', () {
      var pressed = false;
      final action = ErrorAction(
        label: 'Test Action',
        onPressed: () => pressed = true,
      );

      expect(action.label, 'Test Action');
      expect(action.isPrimary, isFalse);
      expect(action.icon, isNull);

      action.onPressed();
      expect(pressed, isTrue);
    });

    test('creates primary action with icon', () {
      final action = ErrorAction(
        label: 'Primary',
        icon: Icons.check,
        isPrimary: true,
        onPressed: () {},
      );

      expect(action.label, 'Primary');
      expect(action.isPrimary, isTrue);
      expect(action.icon, Icons.check);
    });
  });

  group('ErrorSeverity', () {
    test('has all expected values', () {
      expect(ErrorSeverity.values, hasLength(3));
      expect(ErrorSeverity.values, contains(ErrorSeverity.warning));
      expect(ErrorSeverity.values, contains(ErrorSeverity.error));
      expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
    });
  });

  group('ShaderErrorBoundary', () {
    testWidgets('renders child when no shader error occurs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderErrorBoundary(
              child: Text('Shader Content'),
            ),
          ),
        ),
      );

      expect(find.text('Shader Content'), findsOneWidget);
    });

    testWidgets('accepts maxRetries parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderErrorBoundary(
              maxRetries: 5,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('accepts callbacks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderErrorBoundary(
              onShaderError: (error, stack) {},
              onSwitchFractal: () {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('accepts custom fallback widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderErrorBoundary(
              fallback: const Text('Custom Fallback'),
              child: const Text('Normal Content'),
            ),
          ),
        ),
      );

      expect(find.text('Normal Content'), findsOneWidget);
      expect(find.text('Custom Fallback'), findsNothing);
    });
  });

  group('ErrorBoundaryExtension', () {
    testWidgets('withErrorBoundary wraps widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withErrorBoundary(),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(ErrorBoundary), findsOneWidget);
    });

    testWidgets('withErrorBoundary accepts config', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withErrorBoundary(
              config: ErrorBoundaryConfig.shader,
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('withShaderErrorBoundary wraps widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withShaderErrorBoundary(),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(ShaderErrorBoundary), findsOneWidget);
    });

    testWidgets('withShaderErrorBoundary accepts parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withShaderErrorBoundary(
              maxRetries: 5,
              onShaderError: (_, __) {},
              onSwitchFractal: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
