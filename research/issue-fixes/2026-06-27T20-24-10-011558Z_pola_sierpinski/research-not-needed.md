# Pola-Sierpinski low deep zoom

External research not needed. This is local shader behavior at the supplied share params.

Local evidence:
- `pola_sierpinski_gpu.frag` returned flat black for all non-hit pixels.
- Deep zooms can land in a non-hit area, producing a low-detail screen.
- Added nearest-boundary contour coloring for non-hit pixels, preserving hit coloring while giving deep views visible structure.
