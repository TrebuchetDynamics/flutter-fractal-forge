# Cyclic CA low detail

External research not needed. This is local shader sampling behavior at the supplied zoom.

Local evidence:
- `cyclic_ca_gpu.frag` used a fixed `p * 70.0` cell grid after world coordinates were divided by zoom.
- At the reported zoom (~53.25), that leaves only about 1.3 cells across the viewport, causing a blocky low-detail image.
- Added a small zoom-aware grid scale and reused the existing cell mask to keep visible CA structure while preserving the world-coordinate pan/zoom mapping.
