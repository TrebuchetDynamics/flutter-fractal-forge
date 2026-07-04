# Research not needed

Local bad-initial-parameter issue for `multijulia7`.

Source/test evidence:
- The shader fixed `c = (-0.20, 0.70)`, which rendered the default viewport as all interior/black in a local recurrence check.
- Changed the fixed Julia seed to `c = (-0.40, 0.60)` for visible degree-7 escape structure at the default viewport.
- Added CPU recurrence coverage for `multijulia7` and a focused test rendering the default view.
