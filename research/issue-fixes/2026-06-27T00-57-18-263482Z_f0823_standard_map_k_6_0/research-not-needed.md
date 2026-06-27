# Research not needed

Issue: `issues/2026-06-27T00-57-18-263482Z_f0823_standard_map_k_6_0.json`

This is local formula/catalog verification, not an external research question:

- The issue reports `f0823_standard_map_k_6_0` does not look correct / low detail.
- The shared Standard Map catalog registers this identity with `k=6.0` and shader `shaders/strange_attractors/standard_map_gpu.frag`.
- The shader implements the Chirikov standard map update `pNext = mom + K * sin(theta)` and `thetaNext = theta + pNext`, with wrapping to the principal interval.

Acceptance signal: focused shared Standard Map catalog test verifies the K=6 identity and shader asset wiring.
