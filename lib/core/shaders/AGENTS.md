<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# shaders

## Purpose
Dart-side shader utility code. Contains uniform schema definitions that describe the contract between Dart code and GLSL shaders.

## Key Files

| File | Description |
|------|-------------|
| `uniform_schema.dart` | Defines uniform schema types and validation for shader uniform layouts |

## For AI Agents

### Working In This Directory
- This is NOT where GLSL shader files live (those are in project-root `shaders/`)
- This contains Dart code that describes how to talk to the shaders
- Tested in `test/core/shaders/uniform_schema_test.dart`

## Dependencies

### Internal
- Used by `modules/builders/escape_time_builder.dart` for uniform layout

<!-- MANUAL: -->
