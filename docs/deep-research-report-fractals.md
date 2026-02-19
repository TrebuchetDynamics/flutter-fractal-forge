# Shader-Friendly Fractals to Add Beyond Your 338-Module Catalog

## Context and design constraints for GPU-shader fractals

A good rule of thumb for “GPU-shader-friendly” fractals is whether the image can be computed **per pixel** with mostly local data and predictable control flow (bounded loops), or whether it can be computed with a **small number of full-screen passes using ping‑pong textures**. Modern Flutter supports custom **fragment shaders** (via `FragmentProgram` → `FragmentShader`) that run on the user’s GPU, and these shaders can be applied through `Paint.shader` so the shader executes for each pixel in the drawn region. citeturn5search0

That leads to three practical “sweet spots” for a fractal app:

First, **escape-time / iterative complex dynamics** (Mandelbrot-style) are a natural fit because each pixel is independent: you map a pixel to a point (or parameter), iterate a function, and color based on escape behavior. This is the core reason fractals like Mandelbrot/Julia variants are so common in fragment shaders. citeturn5search0

Second, **ray-marched distance-estimated 3D fractals** (Mandelbulb/Mandelbox-class) fit well because you can render implicit surfaces by “sphere tracing” (ray marching using a distance bound). This approach was formalized as *sphere tracing* for implicit surfaces and is valued for robustness when you have a distance function or bound. citeturn4search5turn4search11turn4search33

Third, **simulation / histogram fractals** (reaction–diffusion, fractal flames, Buddhabrot) are usually not “one-pass, stateless” shaders: they depend on accumulation over time (histograms) or on iterating a grid state forward. These can still be GPU-first, but they typically require ping‑pong buffering (or compute) to carry state across steps. citeturn3search28turn9search3turn9search26turn2search0

## High-value gaps relative to your module list

Your current catalog already covers a very wide span of 2D escape-time families, Julia counterparts, a large zoo of attractors/maps, cellular automata, and several 3D entries (including `mandelbulb` and `mandelbox`). The biggest “content-expansion” opportunities that are both visually distinctive and still GPU-centric tend to be:

Distance-estimated 3D families **beyond** the canonical Mandelbulb/Mandelbox, especially fold-based systems (KIFS) and higher-dimensional Julia slices rendered in 3D. These are well-established in distance-estimated fractal literature and real-time approaches. citeturn0search3turn4search7turn6search11turn6search30

“True” **inversive / Kleinian limit-set** style fractals (not just pseudo-kleinians), which are generated from iterated inversions/Möbius actions and have a distinctive “spherical packing / pearl necklace” look. Efficient visualization algorithms based on iterated inversion systems have been published and are conceptually shader-friendly. citeturn7search0turn7search18turn7search5

A dedicated **fractal flame** module family. Fractal flames are a major branch of generative fractal art (IFS-like but with nonlinear “variations” and tone-mapped density), and there is primary literature describing the algorithm. They can be GPU-accelerated, but typically need accumulation/histograms. citeturn2search0turn2search17turn2search20turn2search5

A “proper” **Buddhabrot/Nebulabrot renderer** (not only an approximation), ideally with progressive refinement and importance sampling. This is a known direction for GPU implementations, but it benefits strongly from multi-pass and careful memory handling. citeturn3search5turn3search8

A first-class complex-function visualization mode like **domain coloring** (phase portraits, magnitude/argument encodings). It’s not a single fractal, but it unlocks an entire category of mathematically grounded visuals that map extremely well to fragment shaders. citeturn3search17turn3search37turn3search35

## Distance-estimated 3D fractals to add

image_group{"layout":"carousel","aspect_ratio":"16:9","query":["kaleidoscopic IFS fractal 3D ray marching","quaternion julia set 3D ray marching","mandelbox fractal 3D render","kleinian inversion fractal 3D spheres"],"num_per_query":1}

The following are strong candidates for *new modules* because they are both visually distinct and naturally implemented as **ray-marched distance estimators** (or distance bounds), i.e., the same general rendering family as Mandelbulb/Mandelbox. Sphere tracing is a well-cited foundation for this style of rendering. citeturn4search5turn4search11turn4search33

- **Kaleidoscopic IFS (KIFS) — Menger sponge and fold-based variants** (`kifs_menger`, `kifs_fold_*`)  
  Kaleidoscopic IFS fractals are built from repeated “folding” operations (plus rotation and scaling) and are a standard way to generate distance-estimated structures like the Menger sponge and Sierpiński tetrahedron in a form that is convenient for ray marching. citeturn0search3turn4search7

- **KIFS — Sierpiński tetrahedron (full 3D)** (`kifs_sierpinski_tetra`)  
  If you currently only have a 2D projection/slice module, the fully ray-marched 3D distance-estimated version is a qualitatively different experience (camera motion, lighting, shadows, AO). KIFS formulations for Sierpiński-style solids are explicitly discussed in KIFS literature. citeturn0search3turn4search7

- **Fold-based KIFS “Koch” and snowflake-derived 3D kaleidoscopic solids** (`kifs_koch_fold`, `kifs_snowflake_fold`)  
  Fold systems can produce “Koch-like” kaleidoscopic geometry by repeated reflections/folds; shader-oriented writeups show this directly in fragment-shader form, making it a practical module direction. citeturn0search16turn0search3

- **Quaternion Julia set (3D slice rendered from 4D)** (`quaternion_julia_3d`)  
  A well-known GPU target: you raytrace / raymarch a 3D slice of a quaternion Julia set, leveraging a distance estimator so you can render complex 3D structure interactively. The classic reference explicitly frames “why render these on the GPU?” and provides the GPU-oriented approach. citeturn6search11turn6search4

- **Dual-quaternion Julia fractals** (`dual_quaternion_julia`)  
  This is a newer hypercomplex extension direction: dual-quaternion algebra can be used to realize 3D fractals with Julia-like structure, with published discussion and rendered examples. It’s a credible way to expand your hypercomplex lineup beyond slices and into “new” 3D forms. citeturn6search7turn6search20

- **Mandelbox extensions via generalized shape inversions** (`mandelbox_shape_inversion`)  
  The Mandelbox was originally discovered by Tom Lowe (2010), and later work explores extensions where spherical inversion is replaced with more general “shape inversion,” producing new 2D/3D/4D variants. This is a clean way to add “new” Mandelbox-like modules without just changing a constant. citeturn4search1turn4search27

- **Inversive/Kleinian-style 3D limit sets (iterated sphere inversions)** (`inversive_limit_set_3d`, `kleinian_iis_3d`)  
  There is published work proposing efficient algorithms (Iterated Inversion System / IIS) to visualize Kleinian-group-related inversion fractals, and the same general idea extends naturally to 3D with sphere inversions. If implemented as a distance-estimated ray-marched object, this adds a very distinct “nested spheres / packing” aesthetic. citeturn7search0turn7search18turn7search6turn7search5

- **Time-modulated / animated Mandelbulb variants** (`mandelbulb_time_modulated`)  
  If you want modules that feel genuinely new in motion (not only still images), there is recent literature explicitly describing *time-modulated Mandelbulb* frameworks and GLSL distance-estimator pipelines that inject temporal modulation within the fractal iteration. citeturn0search18turn0search15

## Complex-plane and hypercomplex additions for single-pass fragment shaders

These additions are attractive because they can be **stateless** (each pixel computed independently) and therefore map directly to fragment shaders in the simplest way. Flutter’s fragment shader support is explicitly designed for “evaluate shader for all fragments in a region” workflows. citeturn5search0

- **Domain coloring (complex function visualizer)** (`domain_coloring`)  
  Domain coloring is a standard technique to visualize functions \( f:\mathbb{C}\to\mathbb{C} \) by mapping the complex output to color (often encoding argument as hue and magnitude as brightness/contours). There are GPU/GLSL-focused reports describing domain coloring in the fragment shader. citeturn3search17turn3search37turn3search9

- **Phase portrait mode (argument-only coloring, optional magnitude contours)** (`phase_portrait`)  
  A simpler “module” than full domain coloring, but very effective: visualize the argument/phase of \( f(z) \) as a color wheel. This is often presented as a foundational complex-analysis visualization technique. citeturn3search35turn3search37

- **Alternated-iteration fractals (switch maps per step)** (`alternated_iteration_fractal`)  
  If you alternate two maps (or two parameter sets) during iteration, you can generate connectivity/Julia-like sets with structures not present in standard single-map iteration. There is published work explicitly studying the connectivity sets of alternated iterations and their graphical exploration. citeturn13search19

- **McMullen-family rational maps as first-class presets** (`mcmullen_map`, `generalized_mcmullen`)  
  Even if you already have a generic `rational_map` module, adding named presets matters: McMullen-type families \(z^n + a/z^n + b\) have a literature describing their dynamical behavior and Julia-set topologies and are known to produce “carpet-like” images. citeturn11search21turn11search5

- **Julia sets that are Sierpiński gaskets/carpets (parameterized rational-map presets)** (`sierpinski_julia_rational`)  
  There is active mathematical literature connecting special rational maps (including Misiurewicz-type examples) to Julia sets that are homeomorphic to classical fractals like the Sierpiński gasket, which makes for a clean “math story” module category (and a rich visual one). citeturn11search2turn11search8turn11search4

- **Damped Newton / relaxed Newton basins** (`damped_newton`)  
  “Basins of attraction” fractals are very shader-friendly: iterate a root-finder per pixel and color by the attracting root / convergence rate. Damped Newton variants have published analysis focusing on how damping changes basin boundaries and fractal structure. citeturn15search11turn11search7

- **Weierstrass / Durand–Kerner simultaneous root-finder dynamics** (`durand_kerner_basins`)  
  The Weierstrass (Durand–Kerner) method is a classic “solve all roots in parallel” approach, and modern work analyzes its complex dynamics and non-guaranteed global convergence—precisely the kind of “unexpected dynamics” that yields interesting basin visuals and makes a compelling educational module. citeturn15search19turn15search22turn15search5

- **Ehrlich–Aberth method basins (simultaneous root finding)** (`ehrlich_aberth_basins`)  
  The Aberth–Ehrlich method is another simultaneous root-finder, often discussed alongside Weierstrass/Durand–Kerner and Newton in complex-dynamics treatments. A “basins” visualizer here can make a great companion to Newton/Halley/Householder modules. citeturn11search37turn15search5turn15search29

- **User-shaped Julia sets (shape-driven Julia generation as a workflow/preset system)** (`shape_modulus_julia`)  
  Recent graphics research proposes methods to generate Mandelbrot-like fractals (Julia sets) that approximate a user-defined shape, which could become a signature feature if you treat it as “generate parameters, then render in shader.” citeturn13search32

## Progressive and multi-pass fractals to add

The following are “cool fractals” that are broadly GPU-accelerable, but they typically require **state** (histograms or grid evolution). Practically, that means multi-pass ping‑pong (render-to-texture) or compute-style accumulation. Ping‑ponging (alternating read/write textures each iteration) is a common GPU pattern for reaction–diffusion and similar simulations. citeturn3search28turn3search12turn9search26

image_group{"layout":"carousel","aspect_ratio":"16:9","query":["fractal flame example image","buddhabrot fractal image","gray scott reaction diffusion pattern","lichtenberg figure fractal simulation"],"num_per_query":1}

- **Fractal flames (IFS-with-variations + histogram + tone mapping)** (`fractal_flame`)  
  Fractal flames are a major, distinct family: they extend IFS by adding nonlinear “variations,” then render via density estimation / histogram + tone mapping. The primary algorithm description is published as “The Fractal Flame Algorithm,” and subsequent writeups discuss implementation culture and performance. citeturn2search0turn2search17turn2search20turn2search6

- **Buddhabrot (full) with progressive refinement / importance sampling** (`buddhabrot_full`)  
  Buddhabrot rendering is more computationally intensive than escape-time because it accumulates orbit trajectories into an image. Modern writeups describe GPU-focused implementations and sampling strategies that make it tractable (often with progressive accumulation). citeturn3search5turn3search8

- **Nebulabrot (full, multi-channel) and Anti-Buddhabrot (full)** (`nebulabrot_full`, `anti_buddhabrot_full`)  
  If you already have approximate nebula/anti variants, offering a “progressive full” mode (even at lower resolution or with adaptive sampling) is a meaningful upgrade because the rendering method is fundamentally different: histogramming trajectories rather than pixelwise iteration. citeturn3search8turn3search5

- **Gray–Scott reaction–diffusion patterns (Turing-like morphogenesis)** (`gray_scott_rd`)  
  The Gray–Scott model is famous for producing spots, stripes, and self-replicating motifs from relatively simple reaction–diffusion equations, with classic references (Pearson’s 1993 paper) and accessible explanations. GPU-based PDE/reaction–diffusion implementations are well documented, and real-time creative-coding implementations commonly use ping‑pong textures. citeturn9search19turn9search2turn9search3turn9search26turn3search28

- **Reaction–diffusion textures on arbitrary surfaces (advanced path)** (`reaction_diffusion_surface`)  
  If you ever add 3D meshes or parameterized surfaces, there is published work on generating reaction–diffusion textures directly on surfaces using GPU approaches (CUDA-style), which can become a high-end differentiator. citeturn9search22turn9search15

- **Dielectric Breakdown Model (DBM) / Lichtenberg figure growth** (`dielectric_breakdown`, `lichtenberg_growth`)  
  DBM extends diffusion-limited growth with an electric-field bias and is classically tied to fractal discharge patterns (Lichtenberg figures). The original stochastic model leading to fractal discharge structures is described in the Physical Review Letters literature, and related work discusses simulation of Laplacian growth. This can be implemented as a simulation (grid + field solve + stochastic growth), which is more complex than pixelwise iteration but yields iconic lightning-like branching forms. citeturn12search8turn12search19turn12search13turn12search4

## Flutter integration notes for shader-first fractal modules

Flutter’s official guidance is that custom fragment shaders are supported across both rendering backends (Skia and Impeller) and are integrated by shipping shader assets and instantiating them via the `FragmentProgram` API; the `FragmentShader` is then applied via `Paint.shader` so it runs per fragment in the drawn region. citeturn5search0 The Impeller renderer’s overall goal includes reducing runtime shader compilation issues and improving rendering performance characteristics, and Flutter’s release notes discuss achieving feature completeness on Android’s Vulkan backend (including custom fragment shaders). citeturn5search3turn5search24

For the fractal types above, the implementation implications are straightforward:

Stateless, single-pass fractals (escape-time sets, many rational-map presets, domain coloring) are “best case” for Flutter fragment shaders because they only require uniforms (time, parameters, viewport transform) and no feedback state. citeturn5search0turn3search17

Ray-marched fractals (Mandelbulb/Mandelbox/KIFS/quaternion Julia) can also be single-pass, but you pay for loop-heavy shaders. The canonical approach is sphere tracing: march along a ray by a conservative distance bound to avoid stepping through surfaces, which is exactly what Hart’s sphere tracing formalizes for implicit surfaces. citeturn4search5turn4search33turn4search11 For Mandelbulb/Mandelbox-style distance estimators, published fractal modeling notes show how derivatives/distance estimates are tracked through iteration to accelerate ray marching. citeturn4search7turn2search4turn0search15

Stateful/progressive fractals (reaction–diffusion, flames, Buddhabrot, DBM growth) generally require *feedback*: the next step depends on the previous step’s texture or histogram. In GPU practice this is commonly done with ping‑pong textures (two buffers that swap read/write roles each iteration), an approach explicitly described in modern reaction–diffusion GPU tutorials and examples. citeturn3search28turn9search26turn9search3 In Flutter specifically, if you want more direct control over multi-pass rendering or compute-like workflows, Flutter has also introduced an early-preview low-level graphics API (“Flutter GPU”) intended to enable custom renderers (using Dart + shaders) and it requires Impeller. citeturn5search15