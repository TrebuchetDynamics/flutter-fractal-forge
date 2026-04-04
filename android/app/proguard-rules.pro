# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep app classes
-keep class com.trebuchetdynamics.fractal.forge.** { *; }

# FFmpeg Kit
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }


# Prevent R8 from stripping interfaces
-keep,allowobfuscation,allowshrinking interface * {
    <methods>;
}

# Play Core compatibility for SDK 34+
# Allow missing Play Core Task classes (app doesn't use deferred components)
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitcompat.**
