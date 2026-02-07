# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep app classes
-keep class com.fractals.flutter_fractals.** { *; }

# FFmpeg Kit
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }

# Camera plugin
-keep class io.flutter.plugins.camera.** { *; }

# Prevent R8 from stripping interfaces
-keep,allowobfuscation,allowshrinking interface * {
    <methods>;
}
