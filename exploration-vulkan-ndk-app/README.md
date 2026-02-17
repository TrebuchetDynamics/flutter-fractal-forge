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