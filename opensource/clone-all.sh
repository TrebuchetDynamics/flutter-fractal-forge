#!/bin/bash
# clone-all-fractals.sh - Clone ALL GPU fractal open-source projects
# Combines the verified working set from initial search and the new 2025 findings.
# Usage: ./clone-all-fractals.sh [target-directory] [--with-psych]

set -euo pipefail  # strict mode

TARGET_DIR="${1:-.}"
shift 2>/dev/null || true
WITH_PSYCH=0
if [[ "${1:-}" == "--with-psych" ]]; then
    WITH_PSYCH=1
    shift
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# All repositories (excluding Psychtoolbox-3, which is optional)
REPOS=(
    # Initial working set
    "https://github.com/BrutPitt/glChAoS.P"
    "https://github.com/buddhi1980/mandelbulber2"
    "https://github.com/rafael-fuente/NumbaShader"
    "https://github.com/s-macke/par-fractal"

    # Newly discovered projects (as of early 2025)
    "https://github.com/Greece4ever/Fractals-Explorer"
    "https://github.com/mattsaccount364/FractalShark"
    "https://github.com/YaEnergy/FractalExplorer"
    "https://github.com/bernardocrodrigues/giulia"
    "https://github.com/pedrotrschneider/shader-fractals"

    # GPU fractal survey projects (2026 analytical survey)
    "https://github.com/paulrobello/par-fractal"        # Par Fractal: WebGPU/Rust, 35 fractal types, PBR shading, 60fps
    "https://github.com/NeKon69/MandlebrotSetSFML"      # CUDA Fractal Explorer: NVRTC, dual M/J view, SSAA
    "https://github.com/smurfix/kf2"                    # Kalles Fraktaler 2: perturbation + BLA + series approx, deep zoom benchmark
    "https://github.com/Yilmaz4/MV2"                    # Mandelbrot Voyage 2: GLSL perturbation, TAA, audio-reactive orbits
    "https://github.com/dirkwhoffmann/DeepDrill"        # DeepDrill: GLSL perturbation, spline animation, academic base
    "https://github.com/bernds/GAPFixFractal"           # GAPFixFractal: CUDA 512-bit fixed-point GPU kernels (archived 2022)
    "https://github.com/Shapur1234/Fractl"              # Fractl: WebGPU/Rust/WASM, Multibrot, native + browser targets
    "https://github.com/leoraclet/fractals-generator"   # leoraclet Fractals: emulated double-precision on GPU, Nix, ImGui
    "https://github.com/Krish2882005/FractaVista"       # FractaVista: OpenGL compute shaders, SDL3, C++17 learning resource
    "https://github.com/thargor6/JWildfire"             # JWildfire: Java/CUDA flame fractals, 800+ formulas, MutaGen
)

# Optional: Psychtoolbox-3 (very large, disabled by default)
if [ "$WITH_PSYCH" -eq 1 ]; then
    REPOS+=("https://github.com/Psychtoolbox-3/Psychtoolbox-3")
fi

# Dead/moved URLs that were previously listed (for documentation only)
DEAD_URLS=(
    "https://github.com/gianlucaparadise/fractal-explorer"
    "https://github.com/hrkalona/MV2"
    "https://github.com/LiosLG/GpuMandelbrot"
    "https://github.com/plazma/FractalShaderArbPrec"
)

echo "Cloning all GPU fractal projects into: $(pwd)"
echo "Total repositories to attempt: ${#REPOS[@]}"
echo ""

FAILED=()
SUCCESS=()
SKIPPED=()

for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        echo "⚠️  Skipping $repo_name (already exists)"
        SKIPPED+=("$repo_name")
    else
        echo "🔄 Cloning $repo ..."
        if git clone --depth 1 "$repo" 2>/tmp/clone_error.$$; then
            echo "✅ Cloned $repo_name"
            SUCCESS+=("$repo_name")
        else
            error_msg=$(cat /tmp/clone_error.$$)
            echo "❌ Failed to clone $repo: $error_msg" >&2
            FAILED+=("$repo")
        fi
        rm -f /tmp/clone_error.$$
    fi
done

echo ""
echo "========== SUMMARY =========="
echo "✅ Successfully cloned (${#SUCCESS[@]}):"
printf '   %s\n' "${SUCCESS[@]}"
echo ""
echo "⚠️  Skipped (already existed) (${#SKIPPED[@]}):"
printf '   %s\n' "${SKIPPED[@]}"
echo ""
echo "❌ Failed to clone (${#FAILED[@]}):"
printf '   %s\n' "${FAILED[@]}"
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "The following URLs are known to be dead/moved (from previous lists):"
    printf '   %s\n' "${DEAD_URLS[@]}"
    echo "You may try searching GitHub for alternative names or contact the authors."
fi

echo ""
echo "✅ Done. Happy fractal exploring!"