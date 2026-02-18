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

# Camera plugin
-keep class io.flutter.plugins.camera.** { *; }

# Prevent R8 from stripping interfaces
-keep,allowobfuscation,allowshrinking interface * {
    <methods>;
}

# ARCore / Sceneform (arcore_flutter_plugin 0.1.0 uses old Sceneform 1.13.0
# which references classes no longer present in modern builds; suppress R8 errors)
-dontwarn com.google.ar.sceneform.**
-dontwarn com.google.devtools.build.android.desugar.runtime.**
-keep class com.google.ar.** { *; }
-keep class com.difrancescogianmarco.arcore_flutter_plugin.** { *; }
