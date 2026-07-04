# Fractal scanner sonification: distance + intensity

## Method and limits

- Tooling: `rforge v0.1.14-4-g96621ca-dirty`.
- Queries: see `queries.txt` and `queries2.txt`.
- Sources: `scholarly-fast` attempted first, then `crossref,semantic-scholar` for targeted recovery.
- Coverage: Crossref 80 records, Semantic Scholar 30 records, 91 unique DOIs, 70 library records.
- Limits: OpenAlex returned 503 and Semantic Scholar rate-limited several targeted queries. The literature retrieved supports parameter-mapping and image/spatial sonification; it did not produce a controlled study proving one unique “correct” fractal-to-music mapping.

## Bottom line

Use parameter-mapping sonification, not arbitrary melody: map stable visual measurements to explicit audio parameters. For this app, the user-facing rule should be simple and measurable: **scanner distance controls pitch, visual intensity controls loudness/silence, local detail/color controls timbre, scanner angle controls stereo pan**.

## Evidence themes

1. **Parameter mapping is the right framework.** Barrass & Kramer’s “Auditory Display: Sonification, Audification, and Auditory Interfaces” (Computer Music Journal, 1995, DOI `10.2307/3680606`) and Scaletti’s “Parameter Mapping Sonification” (2011 retrieval record) frame sonification as mapping data dimensions onto sound dimensions. “The Sound of Data: Designing a Framework for Parameter Mapping Sonification” (Leonardo, 2024, DOI `10.1162/leon_a_02568`) reinforces explicit mapping design.
2. **Spatial data can be explored by sound.** “Exploring maps by sounds: using parameter mapping sonification to make digital elevation models audible” (International Journal of Geographical Information Science, 2018, DOI `10.1080/13658816.2017.1420192`) supports parameter mapping for spatial fields rather than reducing the image to one global value.
3. **Images need local texture/intensity cues.** “Audification and sonification of texture in images” (Journal of Electronic Imaging, 2001, DOI `10.1117/1.1382811`) and “Sonification supports perception of brightness contrast” (Journal on Multimodal User Interfaces, 2019, DOI `10.1007/s12193-019-00311-0`) support keeping brightness/contrast as audio-relevant inputs.
4. **Timbre is useful but secondary.** “Toward an effective use of timbre in data sonification” (JASA, 2012, DOI `10.1121/1.4708880`) supports timbre as an encoding channel, but for this UI the user’s requested primary channel is distance-to-pitch.
5. **Mixing must be shaped.** “Adapting Audio Mixing Principles and Tools to Parameter Mapping Sonification Design” (ICAD 2024, DOI `10.21785/icad2024.034`) supports explicit mapping functions and controlled mixing, which argues against summing unlimited bright pixels without gain control.

## Implemented mapping implication

The app now treats each visible scanner ray as distance bins from center to edge:

- black/dark bin: no oscillator for that distance;
- near bright bin: lower pentatonic pitch;
- far bright bin: higher pentatonic pitch;
- brightness/detail: oscillator gain;
- detail/saturation: harmonic/timbre amount;
- scanner angle: stereo pan;
- active-bin normalization: prevents clipping when many bins are bright.

This creates repeatable musical signatures from the rendered frame while preserving the existing fallback deterministic state-based audio when image capture is unavailable.

## Evidence gaps

- No retrieved paper validates this exact fractal scanner mapping against listener perception.
- No human listening study has been run for Flutter Fractal Forge yet.
- Future rigorous work: export generated WAV + frame profiles for selected fractals, run listener AB tests for “does the sound match the visual scanner?”, and compare linear vs logarithmic distance-to-pitch spacing.
