# Control surfaces get their controls from declarations, not module ids

Accepted: the viewer control surfaces read what to draw from the module and parameter declarations instead of matching module or parameter id strings. A parameter's widget comes from `FractalParameter.resolvedControl`, which defaults from its type and accepts an explicit override (a colour stored as an integer, a prime modulus stored as a string). Whether the shared effect controls apply comes from `FractalModule.hidesEffectControls`. Extras that are widgets stay in the feature layer in one table, `moduleControlSections`, because `core/` imports Flutter foundation only. The HUD owns its own height arithmetic in `ControlsHudMetrics`, and the viewer owns region placement in `ViewerChromeLayout`, so a host never re-derives the geometry of the surface it positions.

## Considered Options

- Keep module-id and parameter-id checks in each control surface (the previous behaviour).
- Declare widgets directly on `FractalModule`, which puts `material` widgets in the data layer.
- Declare data in `core/` and keep widget sections in one feature-layer table.

## Consequences

A new module declares once what differs, and control surfaces stop naming fractals. `core/` stays widget-free, and one table entry adds a widget section. A declared control must stay compatible with the stored value type, and `test/features/controls/param_control_declaration_test.dart` fails until a second exception or a second colour-owning module is reviewed. Changing the HUD's header padding now moves the viewer's full-height switch with it. `ViewerChromeLayout` is a pure value type, so the short-viewport rules are tested as data.

Two facts stay outside this model. The HUD's number-wall status live region still tests the module id, because it guards against an asynchronous result that arrives after a module switch; that belongs in the controller, and the guard can move when the race is fixed there. The HUD's `content:` seam has one adapter (the Gaussian map), so the HUD keeps deciding whether it owns the close button until a second host appears.
