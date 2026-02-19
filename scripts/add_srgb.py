#!/usr/bin/env python3
"""
Batch-add linearToSRGB() to all Flutter fractal shaders that are missing it.

Strategy:
  1. Skip shaders that already have linearToSRGB.
  2. Skip diagnostic / non-fractal shaders.
  3. Inject the function definition right after `out vec4 fragColor;`.
  4. Wrap the first argument of every `fragColor = vec4(...)` assignment
     that does NOT start with a literal zero (black pixels must stay black).

Run from project root:
  python3 scripts/add_srgb.py [--dry-run]
"""

import re
import sys
import glob
import os

SRGB_FUNC = """\

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}"""

# Shaders to skip entirely (diagnostics / Flutter built-ins / legacy)
SKIP_BASENAMES = {
    "ink_sparkle.frag",
    "diag_min.frag",
    "diag_9float.frag",
    "diag_sampler.frag",
    "mandelbrot_simple.frag",
    "mandelbrot_hardgrad.frag",
    # Legacy / test shaders — not fractal color outputs
    "mandelbrot.frag",
    "test_always_red.frag",
    "test_flutter_coord.frag",
    "test_gl_fragcoord.frag",
    "test_minimal.frag",
    "test_uniform_only.frag",
}


def find_first_arg_end(line: str, vec4_pos: int) -> int:
    """
    Given a line and the position right after `vec4(`, find the index of the
    comma that separates the first argument from the second, respecting nested
    parentheses.  Returns -1 if not found (shouldn't happen in well-formed GLSL).
    """
    depth = 0
    i = vec4_pos
    while i < len(line):
        ch = line[i]
        if ch == '(':
            depth += 1
        elif ch == ')':
            if depth == 0:
                # Reached closing paren of vec4 without a comma — single-arg
                # (e.g. `vec4(0.0)`) — no wrapping needed at this position.
                return -1
            depth -= 1
        elif ch == ',' and depth == 0:
            return i
        i += 1
    return -1


def wrap_fragcolor_line(line: str) -> str:
    """
    If this line contains `fragColor = vec4(X, ...)` and X is not a literal
    zero, return the line with X wrapped as `linearToSRGB(X)`.
    Multiple vec4() calls on the same line (e.g. ternary) are each processed.
    """
    # Quick guard: skip if no vec4( or already wrapped
    if 'linearToSRGB' in line:
        return line

    result = line
    offset = 0  # tracks how much the string grew due to wrapping

    for m in re.finditer(r'vec4\(', line):
        arg_start = m.end()  # index right after `vec4(`

        # Adjust for previous insertions
        adj_start = arg_start + offset
        adj_line_prefix_end = m.start() + offset  # position of 'v' in 'vec4'

        # Look at what comes right after `vec4(` in the *current* result string
        rest = result[adj_start:]

        # Skip if first arg is a literal zero → black pixel, no sRGB
        stripped = rest.lstrip()
        if stripped.startswith('0'):
            continue

        # Skip if already wrapped (shouldn't reach here but be safe)
        if stripped.startswith('linearToSRGB('):
            continue

        # Find end of first arg in the *original* line (before offset)
        comma_idx = find_first_arg_end(line, arg_start)
        if comma_idx == -1:
            continue

        # Extract the first argument text from the current result
        adj_comma = comma_idx + offset
        first_arg = result[adj_start:adj_comma]

        # Wrap it
        wrapped = f'linearToSRGB({first_arg})'
        result = result[:adj_start] + wrapped + result[adj_comma:]

        # Each wrapping inserts 'linearToSRGB(' (14 chars) and ')' (1 char) = 15 chars
        offset += len(wrapped) - len(first_arg)

    return result


def process_shader(path: str, dry_run: bool) -> bool:
    """Returns True if file was (or would be) modified."""
    with open(path, 'r', encoding='utf-8') as f:
        original = f.read()

    # Already has sRGB → skip
    if 'linearToSRGB' in original:
        return False

    lines = original.split('\n')
    new_lines = []
    injected_func = False

    for line in lines:
        # Inject function definition right after `out vec4 fragColor;`
        if not injected_func and re.match(r'\s*out\s+vec4\s+fragColor\s*;', line):
            new_lines.append(line)
            new_lines.append(SRGB_FUNC)
            injected_func = True
            continue

        # Wrap fragColor color assignments
        if 'fragColor' in line and 'vec4(' in line:
            line = wrap_fragcolor_line(line)

        new_lines.append(line)

    if not injected_func:
        # Shader doesn't have `out vec4 fragColor;` — append function at end of
        # preamble (after last `uniform` line as fallback)
        last_uniform = -1
        for i, l in enumerate(new_lines):
            if re.match(r'\s*uniform\s', l):
                last_uniform = i
        if last_uniform >= 0:
            new_lines.insert(last_uniform + 1, SRGB_FUNC)
            injected_func = True

    if not injected_func:
        print(f"  WARN: could not find injection point in {os.path.basename(path)}")
        return False

    modified = '\n'.join(new_lines)

    if modified == original:
        return False

    if not dry_run:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(modified)

    return True


def main():
    dry_run = '--dry-run' in sys.argv

    shader_dir = os.path.join(os.path.dirname(__file__), '..', 'shaders')
    paths = sorted(glob.glob(os.path.join(shader_dir, '*.frag')))

    modified = 0
    skipped_already = 0
    skipped_denylist = 0

    for path in paths:
        basename = os.path.basename(path)

        if basename in SKIP_BASENAMES:
            skipped_denylist += 1
            continue

        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'linearToSRGB' in content:
            skipped_already += 1
            continue

        changed = process_shader(path, dry_run)
        if changed:
            modified += 1
            print(f"  {'[DRY] ' if dry_run else ''}patched {basename}")

    print(f"\nDone. patched={modified}  already_have_sRGB={skipped_already}  "
          f"skipped_denylist={skipped_denylist}  total={len(paths)}")


if __name__ == '__main__':
    main()
