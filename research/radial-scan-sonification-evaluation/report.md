# Radial scan sonification research note

## Method and limits

Standard-depth sweep for Fractal Music gaps: radial/scan-path image sonification, empty-space silence, constrained musical mappings, loop-boundary clicks, brightness/detail mapping, visual-audio alignment, and accessibility claims. Searches used OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge`; citation expansion was run for five anchor papers. No copyrighted full text was downloaded, so conclusions are based on metadata/search results and citation graphs.

Search coverage: OpenAlex 67 records, Crossref 120 records, Semantic Scholar 5 records, arXiv 120 records, 257 unique DOIs. OpenAlex returned HTTP 504 for two scan-path queries, and one Semantic Scholar file for loop-boundary psychoacoustics was empty.

## Bottom line

The current Fractal Music direction is research-aligned only if it is framed as **explainable scan sonification first, music second**. The literature supports visible scan paths, bounded musical mappings, brightness/contrast sonification, and careful psychoacoustic handling; it does **not** prove the output is beautiful without listening/user tests.

For the observed bug — “random sounds where space is empty” — the best supported product rule is: empty/dark cross-sections should be silent or near-silent, and audible events should be traceable to the visible scanner line.

## Main themes

### 1. Mapping must be explicit and visible

Dubus & Bresin, “A Systematic Review of Mapping Strategies for the Sonification of Physical Quantities” (PLoS ONE, 2013, DOI `10.1371/journal.pone.0082491`) frames sonification as deliberate mapping from data dimensions to acoustic dimensions. For Fractal Music, that argues against random seeded melodies when the UI shows a scanner: beam cross-section brightness/detail should drive pitch/loudness, and empty beam paths should not invent notes.

“Open Your Ears and Take a Look: A State-of-the-Art Report on the Integration of Sonification and Visualization” (Computer Graphics Forum, 2024, DOI `10.1111/cgf.15114`) supports keeping visualization and sonification integrated. Product implication: the visible beam is not decoration; it is the listening cursor.

### 2. Brightness/contrast can be sonified, but thresholds need local tuning

“Sonification supports perception of brightness contrast” (Journal on Multimodal User Interfaces, 2020, DOI `10.1007/s12193-019-00311-0`) is the strongest retrieved support for mapping visual brightness/contrast into sound. It supports using brightness/detail in Fractal Music, but it does not supply a universal silence threshold for fractal screenshots.

Recommended local study: use synthetic frames with known empty, faint, medium, and bright cross-sections; sweep silence thresholds and ask users whether the sound matches what the beam crosses.

### 3. Musical sonification should be constrained

“Sonification with Musical Characteristics: A Path Guided by User-Engagement” (ICAD 2018, DOI `10.21785/icad2018.006`) supports adding musical structure for engagement, but only after the data mapping remains understandable. “Musical Vision: an interactive bio-inspired sonification tool to convert images into music” (Journal on Multimodal User Interfaces, 2019, DOI `10.1007/s12193-018-0280-4`) is directly relevant to image-to-music interfaces.

Product implication: pentatonic quantization is a defensible first constraint. It should be tested against minor/major/chromatic mappings for harshness, repetition fatigue, and perceived visual linkage.

### 4. Loop smoothness matters for perceived quality

The sweep found fewer direct papers on short loop boundary clicks through these sources. Crossref surfaced “Shaping of automatic audio crossfade” (Journal of the Acoustical Society of America, DOI `10.1121/1.404069`) and psychoacoustics chapters, but no app-specific rule for 4-second sonification loops.

Product implication: keep loop starts/ends near zero, or later add a tiny crossfade. Do not claim “pleasant” solely because the notes are pentatonic; loop clicks and restart artifacts can dominate perception.

### 5. Accessibility value is unproven without users

Image/scene sonification papers such as “Interactive sonification of U-depth images in a navigation aid for the visually impaired” (Journal on Multimodal User Interfaces, 2019, DOI `10.1007/s12193-018-0281-3`) and “A Comparative Study in Real-Time Scene Sonification for Visually Impaired People” (Sensors, 2020, DOI `10.3390/s20113222`) show that sonification can be useful in specific navigation/display tasks. They do not prove Fractal Music is accessible or informative for low-vision fractal exploration.

Product implication: keep accessibility claims conservative until tested.

## Proposed local experiments

1. **Scanner causality test**
   - Stimuli: synthetic frames with one bright radial line at known angles plus empty frames.
   - Task: user watches beam and reports whether sound seems to come from beam location.
   - Metrics: causal-link rating, angle identification accuracy, false-positive sounds on empty frames.

2. **Silence threshold sweep**
   - Inputs: brightness/detail ranges from empty black to faint structures.
   - Variables: brightness threshold `0.00–0.05`, detail threshold `0.00–0.05`.
   - Output: constants where empty space is silent but faint visible structure still sounds.

3. **Musical mapping preference test**
   - Compare pentatonic, minor, major, and chromatic quantization on the same scan profiles.
   - Metrics: pleasantness, harshness, fatigue after 60 seconds, perceived relation to image.

4. **Loop artifact test**
   - Compare no crossfade, zero-endpoint envelope, and 20–80 ms crossfade.
   - Metrics: click detection and perceived restart obviousness.

## Implementation implications for Flutter Fractal Forge

- Keep the current **radial scan** path as the first testable mode.
- Keep a visible scan beam; every audible step should come from that beam’s cross-section.
- Use silence gating for empty/dark cross-sections.
- Keep pentatonic notes as a safe first musical vocabulary, but do not call it beautiful without listening tests.
- Add debug/test hooks that expose per-angle brightness/detail scan profiles so synthetic-frame tests can prove the scanner is sampling the displayed cross-section.

## Performance claims hygiene

Do not claim Fractal Music is more beautiful, more accessible, or more informative unless a local listening/user study shows that result. Safe claims are narrower: “the scanner maps beam brightness/detail to bounded pitch/loudness” and “empty cross-sections are gated toward silence.”

## Evidence gaps

- Few direct papers on radial scanner sonification for fractal images.
- No universal silence threshold for visual emptiness.
- No direct proof that pentatonic fractal scan loops are beautiful.
- Limited direct evidence on 4-second loop crossfade best practices for sonification apps.
- Accessibility benefits require low-vision/blind user testing.
