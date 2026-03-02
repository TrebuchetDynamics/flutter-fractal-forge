# Notepad
<!-- Auto-managed by OMC. Manual edits preserved in MANUAL section. -->

## Priority Context
<!-- ALWAYS loaded. Keep under 500 chars. Critical discoveries only. -->

## Working Memory
<!-- Session notes. Auto-pruned after 7 days. -->
### 2026-02-17 01:36
Vulkan NDK MVP built at exploration-vulkan-ndk-app/. Build: `./gradlew assembleDebug` from that dir. Key: ndkVersion="28.2.13676358" must be explicit in app/build.gradle.kts. SPIR-V shaders compiled by CMake on first build, then packaged on second build. All security fixes applied (mutex, SPIR-V alignment, JSON escape, dimension validation).
### 2026-02-18 22:13
arcore_flutter_plugin-0.1.0 pub-cache patches (not in git):
- android/src/main/AndroidManifest.xml: removed package= attribute
- android/build.gradle: added namespace + compileSdkVersion 29→34
- android/src/main/kotlin/.../ArCoreView.kt:390: gestureDetector.onTouchEvent(event) → event?.let { gestureDetector.onTouchEvent(it) } ?: false
These patches are needed for AGP 8.11.1 + Kotlin 2.x builds. Must re-apply after pub cache clear.


## 2026-02-17 01:36
Vulkan NDK MVP built at exploration-vulkan-ndk-app/. Build: `./gradlew assembleDebug` from that dir. Key: ndkVersion="28.2.13676358" must be explicit in app/build.gradle.kts. SPIR-V shaders compiled by CMake on first build, then packaged on second build. All security fixes applied (mutex, SPIR-V alignment, JSON escape, dimension validation).


## MANUAL
<!-- User content. Never auto-pruned. -->

