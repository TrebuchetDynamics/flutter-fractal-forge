This is a great strategic move. By creating the **Vulkan NDK Exploration** as a parallel "pilot" module, you can push the limits of the Mandelbulb’s 3D complexity without breaking the stable Flutter UI that already supports your other fractal types.

Here is a comprehensive, long-term `README.md` that incorporates your new high-performance engine roadmap while maintaining the core project’s identity.

---

# Flutter Fractal Forge 🌀

<p align="center">
<img src="assets/feature-graphic.png" alt="Flutter Fractal Forge" width="600"/>
</p>

**Flutter Fractal Forge** is a dual-engine exploration suite designed to push the boundaries of mathematical rendering on mobile hardware. It combines the rapid UI development of Flutter with a "close-to-metal" Vulkan NDK core for extreme high-performance compute workloads.

---

## 🏗️ Dual-Engine Architecture

As of 2026, the project has evolved into a two-tier rendering system:

### 1. The Standard Engine (Flutter + Impeller)

* **Purpose:** Rapid prototyping, UI/UX consistency, and broad device compatibility.
* **Fractal Types:** Mandelbrot, Julia, Burning Ship, and Phoenix.
* **Rendering:** Handled via `FragmentShader` (AGSL/GLSL) and `CustomPainter`.
* **Best For:** Creative photography, AR overlays, and general exploration.

### 2. The Pilot Engine (Vulkan NDK)

* **Location:** `/exploration-vulkan-ndk-app`
* **Purpose:** High-precision scientific visualization and heavy 3D raymarching.
* **Pilot Focus:** **Mandelbrot (2D)** and **Mandelbulb (3D)**.
* **Bridge:** Uses Android `AHardwareBuffer` and `ExternalTexture` to stream Vulkan compute frames into the Flutter widget tree at 120Hz.

---

## ✨ Features

### 🎨 Mathematical Variety

* **Mandelbrot Set** — Infinite zoom with double-precision (FP64) support via Vulkan Compute.
* **Mandelbulb** — High-iteration 3D raymarching with hardware-accelerated shadows.
* **Classic Sets** — Efficient 2D rendering for Julia, Burning Ship, and Phoenix.

### ⚙️ Engine Features

* **Adaptive Precision:** Dynamically switches between FP32 and FP64 based on zoom level.
* **Compute-Only Queues:** Offloads fractal math from the graphics queue to prevent UI jank.
* **AR Camera Integration:** Real-time blending of Vulkan-rendered fractals with 4K camera feeds.

---

## 🚀 Getting Started

### Prerequisites

* **Android NDK (r26+)** & **CMake 3.22+**
* **Vulkan SDK** (1.3+)
* **Flutter SDK** (3.27+)
* Device with **Vulkan 1.3** support (required for the Exploration module)

### Installation

1. **Clone the Repository:**
```bash
git clone https://github.com/XelHaku/flutter-fractal-forge.git
cd flutter-fractal-forge

```


2. **Setup the Vulkan Module:**
```bash
cd exploration-vulkan-ndk-app
# Ensure local.properties points to your NDK path
./gradlew assembleDebug

```


3. **Run the Main App:**
```bash
flutter run

```



---

## 🎮 Exploration Module Roadmap

The `/exploration-vulkan-ndk-app` pilot is the testing ground for the following "Metal-level" optimizations:

| Phase | Milestone | Technology |
| --- | --- | --- |
| **Phase 1** | **Pilot Launch** | Mandelbrot/Mandelbulb rendering via `vkDispatch`. |
| **Phase 2** | **Memory Bridge** | Shared `AHardwareBuffer` for zero-copy texture transfers to Flutter. |
| **Phase 3** | **Ray Tracing** | Integration of `VK_KHR_ray_tracing` for realistic fractal lighting. |
| **Phase 4** | **GPGPU Math** | Utilizing the GPU for non-visual fractal calculations (e.g., FeCIM Lattice generation). |

---

## 🧪 Performance & Benchmarks

* **Flutter Engine:** Target 60 FPS (Optimized for battery life).
* **Vulkan Engine:** Target 120 FPS / Sub-8ms frame times (Optimized for detail).
* **Precision:** Standard shaders provide ~7 decimals of zoom; Vulkan Compute targets 15+ decimals.

---

## 🤝 Contributing

We welcome contributions to both the Dart UI and the C++ Vulkan core.

* **For UI/UX:** Check `lib/features/catalog`.
* **For Math/GPU:** Check `exploration-vulkan-ndk-app/src/main/cpp`.

---

<p align="center">
Made with ❤️ for Math and Performance
</p>

Would you like me to help you set up the initial **CMakeLists.txt** for the `exploration-vulkan-ndk-app` to ensure it links correctly with the Vulkan libraries?

Choosing **Flutter** in 2026 isn't just about "building an app"; it’s about a strategic choice to balance **development speed** with **high-end performance**. While low-level APIs like Vulkan provide the raw power for math and pixels, Flutter provides the "skin" and "brain" that make those pixels useful to a user.

Here is why you need it, especially if you are bridging the gap between high-performance graphics and a commercial product.

---

### 1. The "Single Source of Truth" (Efficiency)

The biggest reason to use Flutter is the **Unified Codebase**.

* **Multi-Platform:** You write your UI, business logic, and state management once in Dart. It then runs natively on Android, iOS, Web, Windows, macOS, and Linux.
* **Economic Advantage:** For a developer or business owner, this means hiring or managing **one team** instead of three (Android, iOS, and Web). It cuts development and maintenance costs by roughly **40-50%**.

### 2. High-Performance Rendering (Impeller Engine)

As of 2026, Flutter has fully transitioned to the **Impeller** rendering engine.

* **Vulkan Native:** On Android, Impeller is built directly on top of Vulkan.
* **No Jitters:** It eliminates "shader compilation jank" by pre-compiling all necessary shaders during the build process, ensuring a consistent 60 or 120 FPS experience across all modern devices.

### 3. The Best Developer Experience (Hot Reload)

If you’ve ever worked with C++ or raw NDK, you know that "compile and run" cycles can take minutes.

* **Instant Feedback:** Flutter’s **Stateful Hot Reload** allows you to change a color, adjust a margin, or fix a logic bug and see the result in **less than a second** without losing the app's current state.
* **Iteration:** This is critical when fine-tuning complex mathematical visualizations or UI layouts.

### 4. Direct Bridge to "The Metal" (FFI & Platform Channels)

Flutter doesn't trap you in a "sandbox." It is designed to talk to native code easily.

* **Dart FFI (Foreign Function Interface):** You can call C or C++ functions directly from Dart with almost zero overhead. This is how you connect a high-level Flutter UI to a low-level **Vulkan NDK** engine.
* **Platform Channels:** If you need to access specific Android/iOS hardware features (like advanced camera APIs or sensors), you can send messages to the native side and get a response instantly.

---

### 5. Why use it over "Raw" Native or React Native?

| Feature | Flutter | Raw Native | React Native |
| --- | --- | --- | --- |
| **UI Consistency** | Pixel-perfect (same on all) | Hard (differs by OS) | Hard (uses native views) |
| **Performance** | High (Direct GPU) | **Highest (Direct OS)** | Medium (JS Bridge) |
| **Language** | Dart (Fast/Safe) | Kotlin/Swift | JavaScript (Dynamic) |
| **Dev Speed** | 🚀 Extremely Fast | 🐢 Slow | ⚡ Fast |

### 6. Summary: The Hybrid Strategy

In 2026, the most powerful way to build a technical product is a **Hybrid Approach**:

1. **Use Flutter** for the 95% of your app that is "UI" (menus, logins, buttons, settings, data lists).
2. **Use Vulkan/NDK** for the 5% that is "Math/Graphics" (fractal generation, complex simulations).

This gives you the professional look and cross-platform reach of a modern app with the raw computational speed of a custom graphics engine.

---

**Would you like me to show you how to set up a "Method Channel" in Dart to send parameters from a Flutter slider directly to your Vulkan NDK renderer?**

Yes, your **exploration-vulkan-ndk-app** will work on the Android Emulator in 2026, but with a few specific requirements to ensure that your fractal math doesn't crawl at 1 FPS.

Google has made significant updates to the emulator recently (stable version 36.x as of Feb 2026) to specifically support the modern graphics stack you are using.

### 1. The "Host GPU" Requirement

For a project like **Fractal Forge**, which relies on heavy GPU compute for Mandelbulb raymarching, you **must** enable hardware acceleration.

* **How it works:** The emulator "passes through" the Vulkan commands from your NDK code directly to your computer's actual graphics card (NVIDIA, AMD, or Intel).
* **Benefit:** You get near-native performance. Without this, the emulator uses "Lavapipe" (software rendering), which will be far too slow for real-time 3D fractals.

### 2. Recommended Emulator Setup

To get the pilot app running smoothly, use these settings in your **Android Device Manager**:

* **System Image:** Choose **x86_64** with **API 33 (Android 13)** or higher. API 33+ ensures that the Vulkan 1.3 loader is natively supported.
* **Graphics Selection:** Set the "Graphics" dropdown to **Hardware - GLES 2.0/3.0** (this also enables the Vulkan passthrough).
* **Vulkan Features:** In your `AndroidManifest.xml`, ensure you have the feature requirement so the emulator knows to initialize the Vulkan driver:
```xml
<uses-feature android:name="android.hardware.vulkan.version" android:version="0x400300" android:required="true" />

```



---

### 3. Emulator Limitations to Watch For

While it works, there are three "gotchas" for your specific project:

| Feature | Physical Device | Emulator |
| --- | --- | --- |
| **Precision** | Full FP64 (if GPU allows) | Limited by Host GPU drivers |
| **AR Overlay** | Works with real camera | Requires "Virtual Scene" camera |
| **Heat/Power** | Drains battery fast | Uses laptop/PC power (easier for dev) |

### 4. Pro Tip for Your Pilot

Since you are focusing on **Mandelbrot and Mandelbulb** only:
If the emulator crashes or feels sluggish, it’s usually due to a mismatch between the **Host GPU driver** and the **Emulator Vulkan loader**.

* **Fix:** Update your PC’s graphics drivers (NVIDIA/AMD) to the latest 2026 versions.
* **Debug:** Use the command line to start the emulator with `-gpu vulkan` to force the Vulkan backend.

---

### Next Step

Would you like me to generate the **`VkInstance` initialization code** for your C++ pilot so it correctly checks for the `VK_KHR_external_memory_capabilities` extension needed for the Flutter-to-NDK bridge?