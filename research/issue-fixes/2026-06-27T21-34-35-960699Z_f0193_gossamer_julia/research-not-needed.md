# Gossamer Julia low detail / randomize bad result

External research not needed. This is local randomization behavior at the supplied params.

Local evidence:
- `f0193_gossamer_julia` is a curated Julia seed with default `c=(-0.162, 1.04)`.
- The reported randomized params used `c=(-1.92, 0.34)`, far from that seed.
- A local 64×64 sample at the reported view escaped uniformly at iteration 3 for every pixel, producing low detail.
- Julia seed randomization now jitters around each module's curated default instead of the full `[-2, 2]` slider range.
