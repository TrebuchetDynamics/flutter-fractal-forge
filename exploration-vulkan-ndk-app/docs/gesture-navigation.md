# Gesture Navigation System

## 1. Cooperative vs Greedy

| Mode | Behaviour |
|------|-----------|
| cooperative | One finger scrolls; two fingers pan |
| greedy | One finger immediately pans |
| none | All gestures disabled |

## 2. Gestures

### 2.1 Panning

- One-finger pan: Touch down, move. Momentum fling if speed > threshold.
- Two-finger pan: Two touches move together.
- Mouse pan: Click, hold, drag.

### 2.2 Zooming

- Pinch-to-zoom: Two fingers closer/apart. Midpoint fixed.
- Double-tap: 2x zoom at tap point.
- Two-finger tap: 0.5x zoom.
- Mouse wheel: Scroll to zoom.

## 3. State Machine

- touchstart: Add touch, update type
- touchmove: Re-evaluate gesture
- touchend: Start momentum if velocity > threshold

## 4. Velocity

### Pan
Threshold: 0.3 pixels/ms

### Zoom
Threshold: 0.01 zoomLevels/ms

## 5. Momentum

### Pan Fling
friction = 0.95, stop at 0.1 px/frame

### Zoom Fling
friction = 0.92, keep focal point fixed

## 6. Parameters

| Parameter | Value |
|-----------|-------|
| Pan min velocity | 0.3 px/ms |
| Friction | 0.95 |
| Zoom friction | 0.92 |
| Double-tap zoom | 2.0x |
| Tilt range | 0-67.5 deg |
