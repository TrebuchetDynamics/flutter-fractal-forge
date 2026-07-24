# Image-to-music research for Fractal Music

## Method and limits

This was a comprehensive retrieval pass focused on image sonification, visual music, image-conditioned composition, musical mapping, and interactive audiovisual systems. The search used 36 expanded queries across OpenAlex, arXiv, and Semantic Scholar. It retrieved 850 records, 512 deduplicated records, and 513 unique DOI identifiers. Citation expansion was attempted for Musical Vision, the hierarchical image-sonification paper, and Photone. Semantic Scholar rate-limited 22 query requests; the initial `all`-source batch timed out, so the recorded evidence uses the successful OpenAlex/arXiv/Semantic Scholar pass. Full-text acquisition and formal screening were not performed.

## Bottom line

The strongest pattern is **not** “turn every pixel directly into a note.” Successful systems separate the image into feature levels, map different features to different auditory channels, and add a musical composition layer. Low-level color/brightness can drive pitch, loudness, and timbre, while spatial structure, semantic structure, and motion should drive rhythm, density, phrase changes, and interaction.

For Fractal Music, the highest-value next step is a deterministic **image features → musical event grid → synth** pipeline: keep the current radial scan, but summarize it into bars, chord tones, melody notes, rests, bass, and percussion-like texture before rendering. This is cheaper and more controllable than adding an image-to-music ML model.

## What other systems do

### 1. Direct, configurable image sonification

- **Musical Vision** translates color images into harmonic polyphonic music using a bio-inspired visual field, configurable color-to-MIDI/instrument/pitch mappings, and a harmonizer. Its Springer abstract reports a 12-person pilot where participants reached nearly 70% image-interpretation accuracy after less than 25 minutes of training. This is the closest evidence for making mappings both musical and learnable.
  - Source: [Springer article](https://link.springer.com/article/10.1007/s12193-018-0280-4)
  - DOI: [10.1007/s12193-018-0280-4](https://doi.org/10.1007/s12193-018-0280-4)
- **A Hierarchical Visual Feature-Based Approach for Image Sonification** explicitly combines pixel-level color edges and texture, region-level gradients/color distributions, and segmentation-level features. It maps them across notes/octaves, timbre, loudness, pitch, rhythm, and distortion rather than relying on one pitch channel.
  - Source: [DOI](https://doi.org/10.1109/TMM.2020.2987710)
  - Semantic Scholar abstract record: [paper](https://www.semanticscholar.org/paper/2a6f6e6ebc1b740b8288653c061e89f40ecd6f4)
- **Raster-scanning systems** treat an image as a time-ordered signal. They are useful for preserving spatial order, but need smoothing, quantization, and musical grouping to avoid sounding like raw telemetry.
  - Sources: [2008 raster-scanning record](http://hdl.handle.net/2027/spo.bbp2372.2006.008), [2006 record](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.422.4699)

### 2. Interactive visual music

- **Photone** uses global image color plus the pixel under the cursor to generate a dynamic musical score. Moving the cursor changes the music, making exploration part of the composition instead of treating the image as a one-shot input.
  - Source: [Photone DOI](https://doi.org/10.21785/ICAD2018.022)
  - Open paper: [Georgia Tech PDF](https://smartech.gatech.edu/bitstream/1853/60084/1/ICAD2018_022.pdf)
- **Traces of Modal Synergy** studied two months of public-exhibition interaction with Photone. Deeply engaged visitors spent much of their interaction on visually salient objects, while some behavior reflected exploration of image syntax such as color and texture. This supports giving users a meaningful spatial/zoom control rather than only playing a generated loop.
  - Source: [ICAD 2019 DOI](https://doi.org/10.21785/ICAD2019.010)
- **Hearing Images** is an interactive image-sonification interface, reinforcing the pattern that exploration and feedback matter as much as the mapping itself.
  - Source: [EVA 2008 DOI](https://doi.org/10.14236/ewic/eva2008.22)

### 3. Add a composition layer after sonification

- **Spider-web sonification** maps spatial data to pitch, amplitude, and envelope, then uses granular synthesis to turn the resulting building blocks into melody, rhythm, harmony, and chord variations. The important design is the two-stage pipeline: faithful sonification first, musical recomposition second.
  - Source: [Computer Music Journal DOI](https://doi.org/10.1162/comj_a_00580)
  - Open repository copy: [Griffith PDF](https://research-repository.griffith.edu.au/bitstreams/2f6b60ad-564f-4115-b331-c9f3366dd846/download)
- **Erie** provides a declarative grammar for sonification with multiple encoding channels, configurable synthesizers, auditory legends, sequencing, and overlays. Fractal Music does not need the framework, but its separation of mapping and composition is a useful architecture pattern.
  - Source: [ACM DOI](https://doi.org/10.1145/3613904.3642442)
  - arXiv: [2402.00156](https://arxiv.org/abs/2402.00156)

### 4. Semantic, emotional, and motion-conditioned generation

- **PONIFY** extracts human-pose dynamics from paintings and maps perceived dynamics to tempo and musical density. Its evaluation reports better alignment than methods without pose analysis, plus improved enjoyment and empathy. The transferable idea is to map **visual change/dynamics** to rhythm and density, not just color to notes.
  - Source: [PONIFY DOI](https://doi.org/10.1080/10447318.2025.2514876)
- **Emotion-Guided Image to Music Generation** uses valence-arousal conditioning, CNN image features, Transformer MIDI generation, and a valence-arousal loss. It evaluates polyphony rate, pitch entropy, and groove consistency. This is relevant as a long-term ML direction, not a good immediate mobile dependency.
  - Source: [arXiv 2410.22299](https://arxiv.org/abs/2410.22299)
- **Vision-to-Music Generation: A Survey** separates image/video/movement inputs from symbolic-music/audio outputs and catalogs datasets and evaluation metrics. It also points to a maintained research index.
  - Source: [arXiv 2503.21254](https://arxiv.org/abs/2503.21254)
  - Research index: [Awesome-Vision-to-Music-Generation](https://github.com/wzk1015/Awesome-Vision-to-Music-Generation)

### 5. Mapping discipline and evaluation

- A systematic review of 179 sonification publications and 495 mapping entries found pitch was by far the most-used auditory dimension, while proper mapping evaluation was marginal. This is a warning against adding more pitch resolution without testing whether listeners can distinguish or learn it.
  - Source: [PLOS ONE DOI](https://doi.org/10.1371/journal.pone.0082491)
- **A Functional Taxonomy of Music Generation Systems** is useful for distinguishing direct synthesis, symbolic composition, arrangement, and performance-generation layers.
  - Source: [ACM DOI](https://doi.org/10.1145/3108242)

## Implications for the current implementation

Current Fractal Music already has useful foundations: radial image scanning, brightness/detail/hue/saturation extraction, pitch/loudness/stereo mapping, scan smoothing, a diatonic scale, chord roots, and a 24-second loop. The new bounded slice adds a 16-beat phrase grid, chord-tone lead events on strong beats, and deliberate rests on the last beat of each bar. Active image bins still provide the pad/texture layer, so motion-to-rhythm and richer user-controlled phrase exploration remain open.

### Recommended next slices

1. **Aggregate the existing event grid by beat.** The current grid schedules chord-tone leads and rests, but still reads the live scan bins for its pad layer. Aggregate radial bins per beat and emit explicit bass/root, chord pad, lead note, rest, and texture events. Keep the existing deterministic WAV synth.
2. **Use feature roles instead of one mapping.**
   - global hue → key/root;
   - brightness → mode and phrase energy;
   - radial distance → scale degree/register;
   - detail/edge energy → subdivision and texture density;
   - frame-to-frame change → tempo modulation or fills;
   - saturation → timbre/filter amount;
   - scan angle → stereo/pan and phrase position.
3. **Make harmony resolve.** Keep a 4-chord progression, but constrain lead notes to chord tones on strong beats and use scale passing tones on weak beats. Reserve the final beat/bar for a cadence or rest.
4. **Add visual motion as rhythm.** Compare adjacent scan profiles. Stable frames should sustain/decay; changing frames should create attacks, fills, or increased density. This directly applies the PONIFY insight without pose detection.
5. **Add interaction deliberately.** Map zoom or pointer/touch position to phrase position, register, or a bounded variation seed. Avoid restarting the entire musical identity for every tiny visual change.
6. **Evaluate before adding ML.** Generate a fixed panel of fractals and measure event count, pitch entropy, chord-tone rate on strong beats, dynamic range, and loop boundary clicks. Then run a small listening test for perceived correspondence, musicality, and variety. ML image-to-MIDI should wait until deterministic mapping has a measurable ceiling.

## Proposed acceptance criteria

- At least 80% of strong-beat lead events are chord tones.
- Every generated loop has a recognizable 4-bar cadence and no boundary click.
- Brightness/detail changes affect energy and density without changing the selected key unexpectedly.
- Two visually different fractals produce different feature summaries and musical events.
- Zoom/pan changes vary phrase/register while preserving the key and progression.
- A small listener test can identify coarse visual differences above chance; do not claim semantic image reconstruction without a dedicated study.

## Evidence gaps and limits

- Several classic image-sonification records were available only as metadata in the retrieval output; detailed method claims above are limited to the publisher/Semantic Scholar abstracts or source pages that were available.
- No full-text acquisition or formal inclusion/exclusion screening was performed. Those are human-gated in the ResearchForge policy.
- Semantic Scholar returned 429 rate limits for 22 query requests. OpenAlex and arXiv coverage remained non-zero; exact source failures are preserved in `failures.jsonl` and `coverage-stats.log`.
- The research strongly supports mapping and evaluation patterns, but it does not prove that one mapping will sound best for fractal imagery. Audio quality and correspondence still require listening tests.
