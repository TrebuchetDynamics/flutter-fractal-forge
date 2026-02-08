import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exploration_stats.dart';

/// Achievement definitions.
enum Achievement {
  firstZoom('First Zoom', 'Zoomed into a fractal', 0.25),
  zoomMaster('Zoom Master', 'Total zoom distance > 10', 10.0),
  firstScreenshot('First Screenshot', 'Took your first screenshot', 1),
  photographer('Photographer', 'Took 10 screenshots', 10),
  explorer('Explorer', 'Explored 5 different fractals', 5),
  veteran('Veteran', 'Spent 1 hour exploring', 3600);

  final String title;
  final String description;
  final num threshold;

  const Achievement(this.title, this.description, this.threshold);
}

/// Service for tracking exploration statistics.
class ExplorationStatsService extends ChangeNotifier {
  static const _prefsKey = 'exploration_stats_v1';
  static const _achievementsKey = 'unlocked_achievements';

  ExplorationStats _stats = ExplorationStats();
  Set<Achievement> _unlockedAchievements = {};
  SharedPreferences? _prefs;

  ExplorationStats get stats => _stats;
  Set<Achievement> get unlockedAchievements => _unlockedAchievements;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    final stored = _prefs?.getString(_prefsKey);
    if (stored != null) {
      _stats = ExplorationStats.decode(stored);
    }
    final achievements = _prefs?.getStringList(_achievementsKey) ?? [];
    _unlockedAchievements = achievements
        .map((name) {
          try {
            return Achievement.values.firstWhere((a) => a.name == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<Achievement>()
        .toSet();
  }

  Future<void> _save() async {
    await _prefs?.setString(_prefsKey, _stats.encode());
    await _prefs?.setStringList(
        _achievementsKey, _unlockedAchievements.map((a) => a.name).toList());
  }

  /// Record zoom distance traveled (pass absolute log ratio).
  void recordZoom(double oldZoom, double newZoom) {
    if (oldZoom <= 0 || newZoom <= 0) return;
    final distance = (log(newZoom) - log(oldZoom)).abs();
    _stats = _stats.copyWith(
      totalZoomDistance: _stats.totalZoomDistance + distance,
      firstExplorationDate: _stats.firstExplorationDate ?? DateTime.now(),
    );
    _checkAchievements();
    _save();
    notifyListeners();
  }

  /// Record time spent exploring.
  void recordTime(int seconds) {
    _stats = _stats.copyWith(
      totalTimeSeconds: _stats.totalTimeSeconds + seconds,
    );
    _checkAchievements();
    _save();
    notifyListeners();
  }

  /// Alias for recordTime for compatibility (accepts Duration).
  void addExploreTime(Duration duration) => recordTime(duration.inSeconds);

  /// Alias for recordZoom that takes a distance directly.
  void addZoomDistance(double distance) {
    _stats = _stats.copyWith(
      totalZoomDistance: _stats.totalZoomDistance + distance.abs(),
      firstExplorationDate: _stats.firstExplorationDate ?? DateTime.now(),
    );
    _checkAchievements();
    _save();
    notifyListeners();
  }

  /// Record a screenshot/export.
  void recordScreenshot() {
    _stats = _stats.copyWith(
      screenshotsTaken: _stats.screenshotsTaken + 1,
    );
    _checkAchievements();
    _save();
    notifyListeners();
  }

  /// Record exploring a fractal module.
  void recordFractalExplored(String moduleId) {
    final updated = Set<String>.from(_stats.uniqueFractalsExplored)..add(moduleId);
    _stats = _stats.copyWith(
      uniqueFractalsExplored: updated,
      firstExplorationDate: _stats.firstExplorationDate ?? DateTime.now(),
    );
    _checkAchievements();
    _save();
    notifyListeners();
  }

  void _checkAchievements() {
    final newlyUnlocked = <Achievement>[];

    if (!_unlockedAchievements.contains(Achievement.firstZoom) &&
        _stats.totalZoomDistance >= Achievement.firstZoom.threshold) {
      newlyUnlocked.add(Achievement.firstZoom);
    }
    if (!_unlockedAchievements.contains(Achievement.zoomMaster) &&
        _stats.totalZoomDistance >= Achievement.zoomMaster.threshold) {
      newlyUnlocked.add(Achievement.zoomMaster);
    }
    if (!_unlockedAchievements.contains(Achievement.firstScreenshot) &&
        _stats.screenshotsTaken >= Achievement.firstScreenshot.threshold) {
      newlyUnlocked.add(Achievement.firstScreenshot);
    }
    if (!_unlockedAchievements.contains(Achievement.photographer) &&
        _stats.screenshotsTaken >= Achievement.photographer.threshold) {
      newlyUnlocked.add(Achievement.photographer);
    }
    if (!_unlockedAchievements.contains(Achievement.explorer) &&
        _stats.uniqueFractalsExplored.length >= Achievement.explorer.threshold) {
      newlyUnlocked.add(Achievement.explorer);
    }
    if (!_unlockedAchievements.contains(Achievement.veteran) &&
        _stats.totalTimeSeconds >= Achievement.veteran.threshold) {
      newlyUnlocked.add(Achievement.veteran);
    }

    if (newlyUnlocked.isNotEmpty) {
      _unlockedAchievements = {..._unlockedAchievements, ...newlyUnlocked};
    }
  }

  /// Get progress toward an achievement (0.0 to 1.0).
  double getProgress(Achievement achievement) {
    if (_unlockedAchievements.contains(achievement)) return 1.0;
    
    final current = switch (achievement) {
      Achievement.firstZoom || Achievement.zoomMaster => _stats.totalZoomDistance,
      Achievement.firstScreenshot || Achievement.photographer => _stats.screenshotsTaken.toDouble(),
      Achievement.explorer => _stats.uniqueFractalsExplored.length.toDouble(),
      Achievement.veteran => _stats.totalTimeSeconds.toDouble(),
    };
    
    return (current / achievement.threshold.toDouble()).clamp(0.0, 1.0);
  }
}
