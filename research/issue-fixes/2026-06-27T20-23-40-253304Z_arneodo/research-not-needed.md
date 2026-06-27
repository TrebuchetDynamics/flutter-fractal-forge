# Arneodo low detail

External research not needed. The issue is a local shader-quality report for `arneodo` at the supplied share params.

Local evidence:
- `shaders/strange_attractors/arneodo_gpu.frag` colored non-escaped pixels mostly from averaged orbit density and a tiny angle term.
- Added an orbit-trap ridge (`trap`) and flow-speed term (`speedSum`) so adjacent pixels in the supplied view produce more color/brightness variation without changing module IDs or uniforms.
