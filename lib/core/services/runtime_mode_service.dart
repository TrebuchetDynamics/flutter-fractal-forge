import 'package:flutter/widgets.dart';

/// Centralized runtime mode detection used by renderer/viewer/controller.
///
/// Why this exists:
/// - Keeps test/runtime checks in one place (maintainability).
/// - Avoids broad "debug == test" assumptions.
/// - Lets integration tests run the real renderer while widget tests can still
///   use lightweight placeholders.
class RuntimeModeService {
  const RuntimeModeService._();

  static const bool _flutterTestDefine =
      bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

  static const bool forceGpuRender =
      bool.fromEnvironment('FORCE_GPU_RENDER', defaultValue: false);

  static String _bindingTypeName() {
    try {
      return WidgetsBinding.instance.runtimeType.toString();
    } catch (e) {
      debugPrint('[FF] silent catch: $e');
      return '';
    }
  }

  static bool _bindingLooksLikeTest() {
    final name = _bindingTypeName();
    if (name.isEmpty) return false;
    return name.contains('TestWidgetsFlutterBinding') ||
        name.contains('LiveTestWidgetsFlutterBinding') ||
        name.contains('IntegrationTestWidgetsFlutterBinding') ||
        name.contains('AutomatedTestWidgetsFlutterBinding');
  }

  static bool get isAutomatedTest =>
      _flutterTestDefine || _bindingLooksLikeTest();

  static bool get isIntegrationTest {
    final name = _bindingTypeName();
    return name.contains('IntegrationTestWidgetsFlutterBinding');
  }

  /// True only for widget-style tests where the lightweight test surface should
  /// replace real GPU shader rendering.
  ///
  /// Integration tests can still exercise the real renderer by setting
  /// `FORCE_GPU_RENDER=true`.
  static bool get useRendererPlaceholderSurface {
    if (forceGpuRender) return false;
    return isAutomatedTest;
  }
}
