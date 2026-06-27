import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-facing renderer backend preference.
///
/// This setting lets users prefer CPU (stable) or GPU (fast) rendering.
///
/// - [RendererBackendMode.auto]: Use policy + health checks (recommended).
/// - [RendererBackendMode.cpuOnly]: Always use CPU renderer.
/// - [RendererBackendMode.gpuOnly]: Always try GPU renderer (debug).
///
/// Stored in SharedPreferences.
enum RendererBackendMode { auto, cpuOnly, gpuOnly }

class RendererSettingsService extends ChangeNotifier {
  static const String _keyBackendMode = 'renderer_backend_mode';

  final SharedPreferences _prefs;

  RendererBackendMode _backendMode;
  bool _disposed = false;

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  RendererSettingsService(this._prefs)
      : _backendMode = _decode(_prefs.getString(_keyBackendMode));

  static Future<RendererSettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return RendererSettingsService(prefs);
  }

  RendererBackendMode get backendMode => _backendMode;

  Future<void> setBackendMode(RendererBackendMode mode) async {
    if (_backendMode == mode) return;
    _backendMode = mode;
    await _prefs.setString(_keyBackendMode, mode.name);
    _notifyIfAlive();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static RendererBackendMode _decode(String? raw) {
    switch (raw) {
      case 'cpuOnly':
        return RendererBackendMode.cpuOnly;
      case 'gpuOnly':
        return RendererBackendMode.gpuOnly;
      case 'auto':
      default:
        return RendererBackendMode.auto;
    }
  }
}
