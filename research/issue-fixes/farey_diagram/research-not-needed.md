# Farey Diagram performance

External research not needed. The top-level issue file contained only `super bad performance`, and the module is inferable from `issues/farey_diagram.json`.

Local evidence:
- `farey_diagram_gpu.frag` scanned every `np` for every `(q, qp, n)` and then kept only cases where `np*q - n*qp` was ±1.
- Solving that determinant directly gives at most two `np` candidates, removing one nested loop without changing the Farey adjacency criterion.
