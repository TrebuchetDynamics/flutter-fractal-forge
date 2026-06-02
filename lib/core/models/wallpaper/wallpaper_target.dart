/// Platform wallpaper destinations supported by the native wallpaper channel.
///
/// The enum [name] values are the serialized MethodChannel contract used by
/// Android (`home`, `lock`, and `both`). Keep this model separate from the
/// service so wallpaper options can depend on the value type without importing
/// platform integration code.
enum WallpaperTarget {
  home,
  lock,
  both,
}
