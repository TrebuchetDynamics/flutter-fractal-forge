# McMullen Map low detail / deep zoom / randomize bad results

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `mcmullen_map_gpu.frag` returned flat black for non-escaped pixels.
- The reported random/deep view can land in that interior, producing low detail.
- Added interior orbit/trap coloring so those views show structure without changing the map formula or public parameters.
