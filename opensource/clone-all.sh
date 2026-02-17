#!/bin/bash
# clone-all.sh - Clone working GPU fractal projects (2025 update)
# Usage: ./clone-all.sh [target-directory] [--with-psych]

set -e

TARGET_DIR="${1:-.}"
shift 2>/dev/null || true
WITH_PSYCH=0
if [[ "$1" == "--with-psych" ]]; then
    WITH_PSYCH=1
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

REPOS=(
    "https://github.com/BrutPitt/glChAoS.P"
    "https://github.com/buddhi1980/mandelbulber2"
    "https://github.com/rafael-fuente/NumbaShader"
    "https://github.com/s-macke/par-fractal"
)

if [ "$WITH_PSYCH" -eq 1 ]; then
    REPOS+=("https://github.com/Psychtoolbox-3/Psychtoolbox-3")
fi

echo "Cloning into: $(pwd)"
for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        echo "⚠️  Skipping $repo_name (already exists)"
    else
        echo "🔄 Cloning $repo ..."
        if git clone --depth 1 "$repo"; then
            echo "✅ Cloned $repo_name"
        else
            echo "❌ Failed to clone $repo" >&2
        fi
    fi
done

echo ""
echo "✅ Done. Working projects cloned."
echo "ℹ️  The following URLs were not found and were skipped:"
echo "   - https://github.com/gianlucaparadise/fractal-explorer"
echo "   - https://github.com/hrkalona/MV2"
echo "   - https://github.com/LiosLG/GpuMandelbrot"
echo "   - https://github.com/plazma/FractalShaderArbPrec"
echo ""
echo "If you need those, try searching GitHub for similar keywords or contact the authors."