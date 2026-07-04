# Fractal Music Listening Checklist

Use this checklist before closing work on Fractal Music sound quality. Automated tests and preview manifests catch structure, clipping, silence, and sync regressions, but they do not prove the music is pleasant on real speakers/headphones.

## Generate Preview WAVs

Interactive review helper:

```sh
scripts/review-fractal-music-previews.sh /tmp/fractal_music_preview_review
```

Or generate only:

```sh
scripts/generate-fractal-music-previews.sh /tmp/fractal_music_preview_review
```

Confirm `/tmp/fractal_music_preview_review/manifest.json` reports `"health": "pass"` and empty `issues` for every WAV.

## Listen To Representative Previews

- `01-dark-silence.wav` — should be silent.
- `02-red-field.wav` — should be soft, stable, and not piercing.
- `03-cyan-field.wav` — should be audibly different from red while similarly gentle.
- `04-right-edge-detail.wav` — should pan/move with detail without harsh clicks.
- `05-state-fallback.wav` — should be acceptable when screen capture is unavailable.

## In-App Device Check

On at least one real playback path, preferably headphones plus device speaker:

1. Open a bright/colorful fractal and enable Fractal Music.
2. Verify the scan overlay starts at the same time as the audio loop.
3. Switch palettes/params and verify music changes after the debounce without overlap.
4. Leave an animated/time-varying visual running for at least 3 loops; verify music keeps matching rather than becoming stale.
5. Disable music and verify playback stops immediately.

## Pass Criteria

- No clipping, popping, stuck playback, or overlapping loops.
- Music is gentle enough for repeated listening at normal device volume.
- Distinct visual colors/details produce distinct audible results.
- Audio timing feels attached to the visible scan overlay.

Record reviewer, device/output, date, and notes in the issue/PR before marking the Fractal Music revamp complete. The review helper writes a starter report to `/tmp/fractal_music_preview_review/listening-review.md`.
