import 'package:shared_preferences/shared_preferences.dart';

/// Owns text-overlay state, SharedPreferences persistence, and the
/// [activeQuoteText] null-guard so callers never inspect raw fields.
class TextOverlayController {
  static const _kEnabledKey = 'text_overlay_enabled';
  static const _kTextKey = 'text_overlay_text';

  bool _enabled = false;
  String _text = '';

  bool get enabled => _enabled;
  String get text => _text;

  /// Non-null only when enabled and text is non-empty after trimming.
  String? get activeQuoteText =>
      _enabled && _text.trim().isNotEmpty ? _text.trim() : null;

  /// True when [text] is empty — caller must open an edit dialog before toggling.
  bool get needsEditBeforeToggle => _text.trim().isEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabledKey) ?? false;
    _text = prefs.getString(_kTextKey) ?? '';
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, _enabled);
    await prefs.setString(_kTextKey, _text);
  }

  /// Flips [enabled]. Only call when [needsEditBeforeToggle] is false.
  void toggle() {
    assert(!needsEditBeforeToggle);
    _enabled = !_enabled;
  }

  /// Commits text from the edit dialog; enables iff the trimmed result is non-empty.
  void applyEdit(String rawText) {
    _text = rawText.trim();
    _enabled = _text.isNotEmpty;
  }
}
