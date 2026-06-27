# Inverse Life bad initial params

External research not needed. This is local catalog default configuration.

Local evidence:
- `shared_residual_ca_catalog.dart` gave every residual CA module the same default `iterations: 260`.
- The issue report identifies `f1013_inverse_life_b0123478_s34678` with `iterations: 436`.
- Set only this module's default iteration count to 436; birth/survival masks remain the reviewed B0123478/S34678 rule.
