#!/usr/bin/env bash
set -u
queries=(
  "data sonification images sound mapping pitch timbre"
  "audification numerical data image sonification"
  "image sonification raster scanning color pitch timbre"
  "spectrogram inversion image to sound"
  "fractal music algorithmic composition self similarity"
  "MIDI data sonification musical parameter mapping"
  "psychoacoustics auditory display sonification mapping"
  "procedural audio synthesis generative music real time"
)
slugs=(
  "data-sonification-images"
  "audification-image-data"
  "image-sonification-raster-color"
  "spectrogram-inversion-image-sound"
  "fractal-music-composition"
  "midi-data-mapping"
  "psychoacoustics-auditory-display"
  "procedural-audio-generative"
)
sources=(openalex crossref semantic-scholar arxiv)
for i in "${!queries[@]}"; do
  q="${queries[$i]}"
  slug="${slugs[$i]}"
  for source in "${sources[@]}"; do
    out="search-${source}-${slug}.txt"
    echo "== $source :: $q ==" >&2
    rforge search --source "$source" --query "$q" --limit 20 > "$out" 2>&1 || true
  done
done
