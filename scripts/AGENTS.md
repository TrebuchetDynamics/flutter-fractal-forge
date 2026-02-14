<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# scripts

## Purpose
Shell scripts for development automation, testing, and screenshot generation. Used for emulator control, overnight test runs, and store listing screenshots.

## Key Files

| File | Description |
|------|-------------|
| `desktop-screenshots.sh` | Captures desktop app screenshots for store listing |
| `emu-status.sh` | Check Android emulator status |
| `emu-tap.sh` | Send tap events to emulator |
| `overnight-emulator-loop.sh` | Long-running emulator test loop |
| `overnight-ui-monkey.sh` | Random UI interaction stress testing |

## For AI Agents

### Working In This Directory
- Scripts are bash and intended for Linux environments
- Emulator scripts target Android emulators via `adb`
- Screenshot scripts may need display/window manager access

<!-- MANUAL: -->
