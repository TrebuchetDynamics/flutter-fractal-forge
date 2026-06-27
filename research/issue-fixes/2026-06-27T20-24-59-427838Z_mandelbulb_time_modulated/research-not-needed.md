# Time-Modulated Mandelbulb low deep zoom

External research not needed. This is local raymarch miss coloring behavior.

Local evidence:
- `mandelbulb_time_modulated_gpu.frag` returned only a vertical background gradient on ray misses.
- The reported view can miss the surface, making the deep view low-detail.
- Ray marching now tracks the closest distance/position and uses it for a soft miss glow, while hit rendering is unchanged.
