# 3D Koch Snowflake no-image issue

## Method and limits

Searched OpenAlex, Crossref, Semantic Scholar, and arXiv with three query variants covering Koch snowflake IFS construction, 3D/KIFS forms, and ray-marched distance estimators. No full text was downloaded.

## Bottom line

A Koch snowflake-style 3D renderer needs reachable repeated folds/IFS transforms and a ray-march hit threshold large enough to intersect the distance field. The local failure was not catalog identity: the module points at a bundled KIFS Koch shader, but the old fold tests ran after `abs(p)` and were unreachable, making the object effectively invisible.

## Evidence

- Crossref found **"Generating Iterated Function Systems for the Vicsek Snowflake and the Koch Curve"**, DOI `10.4169/amer.math.monthly.123.7.716`, supporting IFS/fold construction as the right model for Koch-like fractals.
- Crossref found **"Interactive Procedural Building Generation Using Kaleidoscopic Iterated Function Systems"**, DOI `10.1007/978-3-319-27857-5_10`, supporting KIFS as a procedural geometry technique.
- Local validation checks the live `f0598_3d_koch_snowflake` module uses `shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag`, contains reachable sorted/tetrahedral fold conditions, does not contain the dead `p.x + p.y < 0.0` fold, and uses the raised ray-hit tolerance/ambient light.

## Project implication

Keep the small shader fix. Do not add a separate 3D Koch renderer or rewrite the 3D catalog unless additional 3D modules fail the same visibility check.
