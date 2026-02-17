# Gesture Specification - Google Maps Style

## Pan (1-finger drag)
| Parameter | Value |
|-----------|-------|
| Mapping | pixels / zoom |
| Min zoom divisor | 1e-9 |
| Fling threshold | 5 px/frame |
| Fling friction | 0.95 |
| Stop threshold | 0.1 px/frame |
| Mode | greedy |

## Two-Finger Pan
| Parameter | Value |
|-----------|-------|
| Trigger | 2 fingers down |
| Tracking | Average movement |

## Zoom (pinch)
| Parameter | Value |
|-----------|-------|
| Min zoom | 1e-10 |
| Max zoom | 1e10 |
| Zoom fling threshold | 0.01 |
| Zoom fling friction | 0.92 |

## Two-Finger Tap
| Parameter | Value |
|-----------|-------|
| Zoom factor | 0.5 |

## Double-tap
| Parameter | Value |
|-----------|-------|
| Zoom factor | 2.0 |
| Animation | 200ms |

## Mouse Wheel
| Parameter | Value |
|-----------|-------|
| Sensitivity | deltaY * 0.001 |

## 3D Rotation
| Parameter | Value |
|-----------|-------|
| 2-finger rotate | Full 360 |

## Tilt
| Parameter | Value |
|-----------|-------|
| Range | 0-67.5 degrees |

## Boundary
| Parameter | Value |
|-----------|-------|
| Strength | 0.5 |

## Implementation Status
| Gesture | Status |
|---------|--------|
| Pan 1-finger | DONE |
| Pan fling | DONE |
| Zoom pinch | DONE |
| Zoom fling | DONE |
| Double-tap | DONE |
| Two-finger tap | DONE |
| Mouse wheel | DONE |
| 2-finger rotate | DONE |
| Tilt | DONE |
| Boundary rubber-band | DONE |

## Implementation Notes
- Two-finger tap (quick dual-pointer up within 220ms) triggers 0.5x zoom-out with 200ms easing + haptic: `lib/features/renderer/fractal_renderer.dart#L771-L785`, `#L808-L834`.
- Mouse wheel zoom (greedy, no Ctrl modifier) uses `deltaY * 0.001` exponential sensitivity and focal-point anchoring: `lib/features/renderer/fractal_renderer.dart#L796-L806`.
- Two-finger rotation updates full Z rotation and keeps midpoint world anchor fixed while rotating+zooming: `lib/features/renderer/fractal_renderer.dart#L644-L663`.
- Tilt uses two-finger vertical swipe with sensitivity `0.01 rad/pixel`, clamped to `0..67.5°`, with no momentum on lift: `lib/features/renderer/fractal_renderer.dart#L623-L642`, `#L681-L687`.
- Rubber-banding (`strength=0.5`) applied to pan + zoom, including momentum edge damping/bounce-back velocity reduction: `lib/features/renderer/fractal_renderer.dart#L519-L524`, `#L257-L264`, `#L297-L308`, `#L621`, `#L656-L659`.
- Pointer listener wiring for raw 2-finger tap / wheel gesture capture in all renderer modes (test/cpu/gpu): `lib/features/renderer/fractal_renderer.dart#L1051-L1086`, `#L1128-L1141`, `#L1235-L1248`.
