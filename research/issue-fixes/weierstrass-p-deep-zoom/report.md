# Weierstrass-p deep-zoom issue

## Method and limits

Searched OpenAlex, Crossref, Semantic Scholar, and arXiv with three query variants covering the Weierstrass elliptic p-function, numerical evaluation, and float32/deep-zoom shader precision. Semantic Scholar returned HTTP 429 rate-limit responses. No full text was downloaded.

## Bottom line

The issue is local rendering precision, not missing catalog identity: at the reported zoom (`413329`) GPU float32 coordinate precision is too coarse for a Weierstrass-p shader. The minimal fix is to use the native CPU formula for `weierstrass_p` once zoom reaches this range.

## Evidence

- OpenAlex found **"Connectivity of Julia sets for Weierstrass elliptic functions on square lattices"**, DOI `10.1090/s0002-9939-2011-11079-7`, confirming Weierstrass elliptic functions are used as Julia/fractal iteration maps.
- Crossref found reference entries for **"The Weierstrass ℘-Function"** and **"The Weierstrass elliptic functions"**, matching the local CPU implementation's lattice-sum style around poles.
- Local verification is the acceptance signal: `test/weierstrass_p_deep_zoom_test.dart` asserts `weierstrass_p` has a native CPU formula and that the reported zoom routes through `DeepZoomPrecisionPolicy.shouldUseCpuFallback`.

## Project implication

Keep the small CPU fallback and lowered threshold. Do not rewrite the shader or add a higher-precision GPU system unless more deep-zoom modules show the same failure.
