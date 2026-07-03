import 'package:equatable/equatable.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_target.dart';

export 'package:flutter_fractals/core/models/wallpaper/wallpaper_target.dart';

/// Lightweight post-processing overlays to improve icon/clock legibility.
enum WallpaperStyle {
  plain,
  homeOptimized,
  lockOptimized,
}

class WallpaperOptions extends Equatable {
  final WallpaperTarget target;
  final WallpaperStyle style;

  /// If true, also saves a copy to the app export folder (and can be shared).
  final bool saveCopy;

  const WallpaperOptions({
    this.target = WallpaperTarget.home,
    this.style = WallpaperStyle.homeOptimized,
    this.saveCopy = true,
  });

  WallpaperOptions copyWith({
    WallpaperTarget? target,
    WallpaperStyle? style,
    bool? saveCopy,
  }) {
    return WallpaperOptions(
      target: target ?? this.target,
      style: style ?? this.style,
      saveCopy: saveCopy ?? this.saveCopy,
    );
  }

  @override
  List<Object?> get props => [target, style, saveCopy];
}
