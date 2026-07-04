# Research not needed

Local uniform/config bug for `jacobi_sn`.

Source/test evidence:
- `jacobi_sn_gpu.frag` declares extra uniform `uK` at slot 10.
- The catalog entry had no `extraParams`, so the standard escape-time builder never wrote slot 10.
- Added the missing `k` parameter with default `0.5` and a CPU recurrence for focused render validation.
- Focused tests verify the parameter binding contract and render the reported view.
