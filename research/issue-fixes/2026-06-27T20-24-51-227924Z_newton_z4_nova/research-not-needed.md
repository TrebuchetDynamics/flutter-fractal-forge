# Newton z4 Nova low deep zoom

External research not needed. This is local shader coloring behavior at the supplied deep zoom.

Local evidence:
- `newton_z4_gpu.frag` colored mostly by iteration count and nearest root phase.
- Deep zooms inside one root basin can therefore collapse to nearly one color.
- Added basin-shade terms from Newton step travel and minimum step length, preserving root coloring while adding intra-basin detail.
