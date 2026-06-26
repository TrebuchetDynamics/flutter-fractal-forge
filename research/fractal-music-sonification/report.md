# Fractal music and image sonification research note

## Method and limits

This standard-depth sweep searched OpenAlex, Crossref, Semantic Scholar, and arXiv for eight query variants around data sonification, audification, image sonification, spectrogram inversion, fractal music, MIDI/data mapping, psychoacoustics, and procedural audio. It used metadata/search results and citation graphs only; no copyrighted full text was downloaded. Semantic Scholar rate-limited most queries, so OpenAlex/Crossref/arXiv carry most of the evidence.

## Bottom line

The literature supports a fractal-audio feature as **sonification first, music second**: define a clear mapping from fractal data to sound parameters, then tune it for perception and aesthetics. The safest product path is not “turn pixels into songs” as one opaque trick, but a few named modes: scan-based image sonification, raw/filtered audification of iteration streams, and optional musical/MIDI mapping.

## Main themes

### 1. Sonification mapping is the core design problem

The broad anchor is Dubus & Bresin, “A Systematic Review of Mapping Strategies for the Sonification of Physical Quantities” (PLoS ONE, 2013, DOI `10.1371/journal.pone.0082491`). It frames sonification as mapping data dimensions onto acoustic dimensions, which directly matches fractal parameters such as escape iteration, distance estimate, orbit trap value, angle, zoom, and color index.

Recent terminology and visualization integration work is also relevant: “Towards a unified terminology for sonification and visualization” (Personal and Ubiquitous Computing, 2023, DOI `10.1007/s00779-023-01720-5`) and “Open Your Ears and Take a Look: A State-of-the-Art Report on the Integration of Sonification and Visualization” (Computer Graphics Forum, 2024, DOI `10.1111/cgf.15114`). For Fractal Forge, this argues for keeping visual and audio controls linked: users should hear what is selected, scanned, or animated, not a disconnected soundtrack.

### 2. Audification is viable, but needs filtering and time scaling

Focused audification directly interprets numeric data as sound, but practical work emphasizes choosing parameters carefully. “Focused Audification and the optimization of its parameters” (Journal on Multimodal User Interfaces, 2020, DOI `10.1007/s12193-019-00317-8`) is the best retrieved anchor.

For fractals, raw escape iteration values or orbit traces can become waveform/control signals, but the raw stream will often be harsh, aliased, or silent. Treat audification as an expert/experimental mode with normalization, DC removal, clipping protection, and playback-rate control.

### 3. Image sonification exists mostly as task-specific auditory display

The sweep found stronger evidence for applied image/scene sonification than for one canonical “raster image to music” method. Examples include “Using the Sonification for Hardly Detectable Details in Medical Images” (Scientific Reports, 2019, DOI `10.1038/s41598-019-54080-7`), “Interactive sonification of U-depth images in a navigation aid for the visually impaired” (Journal on Multimodal User Interfaces, 2019, DOI `10.1007/s12193-018-0281-3`), and “A Comparative Study in Real-Time Scene Sonification for Visually Impaired People” (Sensors, 2020, DOI `10.3390/s20113222`).

For a fractal app, raster scan, spiral/polar scan, and contour-following are implementation choices, not settled science. The mapping should expose the scan path because the path becomes the rhythm/form.

### 4. Spectrogram inversion is useful only if the image is defined as a spectrogram

“Inversion of auditory spectrograms, traditional spectrograms, and other envelope representations” (IEEE/ACM TASLP, 2014, DOI `10.1109/taslp.2014.2367821`) supports the idea that some visual time-frequency representations can be turned back into audio. But a fractal image is not automatically a spectrogram: time, frequency, magnitude, and phase assumptions must be invented.

Use this as a special mode: treat x as time, y as frequency, brightness/color as magnitude/timbre, then synthesize with overlap-add or oscillator banks. Do not present it as physically “recovering” sound from the fractal.

### 5. Fractal and algorithmic music research supports structure, not automatic beauty

“Fractal dimension and classification of music” (Chaos, Solitons & Fractals, 2000, DOI `10.1016/s0960-0779(99)00137-x`) connects fractal measures to music analysis. “AI Methods in Algorithmic Composition: A Comprehensive Survey” (Journal of Artificial Intelligence Research, 2013, DOI `10.1613/jair.3908`) gives the broader algorithmic-composition context.

The product implication is modest: fractal self-similarity can drive repetition, variation, phrase length, density, and motif recurrence. It does not guarantee pleasant music without scale constraints, rhythm constraints, and user taste controls.

### 6. Musical parameter mapping and MIDI should be constrained

Musical sonification work retrieved includes “Sonification with Musical Characteristics: A Path Guided by User-Engagement” (ICAD 2018, DOI `10.21785/icad2018.006`) and “Interactive Spatial Sonification of Multidimensional Data for Composition and Auditory Display” (Computer Music Journal, 2016, DOI `10.1162/comj_a_00358`). These support using musical structures when the goal is engagement, not only data inspection.

For Fractal Forge, map fractal values to a small musical vocabulary first: scale, root, tempo, note density, octave, velocity, and instrument. Avoid dozens of arbitrary knobs until users ask for them.

### 7. Psychoacoustics and evaluation matter

“Evaluation of psychoacoustic sound parameters for sonification” (ACM ICMI, 2017, DOI `10.1145/3136755.3136783`) and “PAMPAS: A PsychoAcoustical Method for the Perceptual Analysis of multidimensional Sonification” (Frontiers in Neuroscience, 2022, DOI `10.3389/fnins.2022.930944`) point to perception-aware mapping. “Is Sonification Doomed to Fail?” (ICAD 2019, DOI `10.21785/icad2019.069`) is a useful warning: novelty is not enough; users need legible, useful listening tasks.

Practical rules: avoid continuous loud high frequencies, keep loudness bounded, let users mute/solo layers, and label what each sound dimension means.

### 8. Procedural audio is the real-time implementation bucket

“Procedural Audio in Computer Games Using Motion Controllers: An Evaluation on the Effect and Perception” (International Journal of Computer Games Technology, 2013, DOI `10.1155/2013/371374`) is not fractal-specific, but it fits the interactive setting: synthesize sound from runtime state instead of pre-rendering everything.

For Flutter Fractal Forge, procedural audio means audio responds to pan, zoom, parameter animation, selected point, or shader time without exporting an offline track first.

## Performance claims hygiene

No retrieved paper should be used to claim that a fractal-audio mapping is “more musical,” “more informative,” or “better for accessibility” without a user study. Cite exact papers for exact claims, distinguish metadata/abstract-derived claims from full-text evidence, and treat headline claims as context-specific.

## Evidence gaps

- Few retrieved results directly study fractal images converted to music in modern app contexts.
- Raster/spiral/polar scan choices need local prototyping and listening tests.
- Accessibility value for blind/low-vision users cannot be assumed from aesthetics-focused sonification.
- Real-time mobile/Flutter audio latency was not covered by this literature sweep.
- Semantic Scholar was rate-limited, reducing CS/music retrieval breadth.

## Implications for Flutter Fractal Forge

Start with the smallest useful feature set:

1. **Scan sonification**: scan the rendered fractal or an offscreen sample grid; map brightness/iteration to pitch and loudness, color/hue to timbre or pan.
2. **Point/orbit mode**: let a selected point’s orbit or escape sequence drive a short loop; this is more fractal-native than generic pixel scanning.
3. **MIDI/export mode later**: quantize values to a scale and tempo only after the raw sonification feels controllable.

Keep every sound mode explainable in UI text: “brightness controls pitch,” “escape speed controls rhythm,” etc. That gives users a listening model and makes the feature easier to test than an opaque generative-music engine.
