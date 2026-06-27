# Celtic Power5 Julia bad initial coordinates/params

External research not needed. This is local shader behavior for the reported start state.

Local evidence:
- `celtic_power5_julia_gpu.frag` returned flat black whenever the reported coordinates/params did not escape by the iteration cap.
- That makes bad/random initial states unrecoverably blank-looking.
- Added interior orbit/trap coloring so the reported initial state still has visible structure without changing the Celtic map formula.
