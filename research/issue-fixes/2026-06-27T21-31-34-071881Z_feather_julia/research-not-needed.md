# Feather Julia zoom does not affect interior texture

External research not needed. This is local shader coordinate use.

Local evidence:
- `feather_julia_gpu.frag` initializes the Julia point as `uv / uZoom + uCenter`.
- Its bounded/interior coloring ignored that zoomed coordinate and used `uv + uCenter` instead.
- In reported zoomed-out views dominated by bounded pixels, the visible plume/barb texture therefore barely responded to zoom.
- Reused the initial zoomed coordinate (`z0`) for interior plume/barb coloring.
