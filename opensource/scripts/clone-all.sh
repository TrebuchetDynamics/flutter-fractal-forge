#!/usr/bin/env bash
# Clone the open-source fractal reference landscape into opensource/repos.
#
# These clones are for studying algorithms, rendering pipelines, API shapes,
# parameters, and tests. Check each repository's LICENSE before copying code into
# Flutter Fractal Forge.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/../repos"
INCLUDE_LARGE=0
UPDATE_EXISTING=0
DRY_RUN=0
FULL_HISTORY=0
VERIFY_ONLY=0
CATEGORY_FILTER=""

usage() {
  cat <<'USAGE'
Usage: scripts/clone-all.sh [target-directory] [options]

Clone the saved open-source fractal generator landscape for reference study.
Default target: opensource/repos

Options:
  --target DIR       Clone into DIR instead of opensource/repos.
  --category NAME    Clone only one top-level category, e.g. browser-webgpu.
  --with-large       Include very large optional repositories such as Psychtoolbox-3.
  --with-psych       Alias for --with-large.
  --full             Clone full history instead of shallow --depth 1 clones.
  --update           Run git pull --ff-only for repositories that already exist.
  --verify           Only verify that listed remotes are reachable with git ls-remote.
  --dry-run          Print clone/update actions without running them.
  --list-categories  Print available top-level categories and exit.
  -h, --help         Show this help.

Examples:
  scripts/clone-all.sh --dry-run
  scripts/clone-all.sh --category deep-zoom --update
  scripts/clone-all.sh /tmp/fractal-refs --with-large --full
USAGE
}

# dest-relative-to-target|git-url|flags
# Flags: optional-large means skipped unless --with-large/--with-psych is passed.
REPOS=(
  # Existing Flutter Fractal Forge reference set.
  "formula-catalogs/glChAoS.P|https://github.com/BrutPitt/glChAoS.P|"
  "formula-catalogs/mandelbulber2|https://github.com/buddhi1980/mandelbulber2|"
  "formula-catalogs/JWildfire|https://github.com/thargor6/JWildfire|"
  "formula-catalogs/shader-fractals|https://github.com/pedrotrschneider/shader-fractals|"
  "renderers/interactive-cpp/FractalExplorer|https://github.com/YaEnergy/FractalExplorer|"
  "renderers/interactive-cpp/Fractals-Explorer|https://github.com/Greece4ever/Fractals-Explorer|"
  "renderers/interactive-cpp/giulia|https://github.com/bernardocrodrigues/giulia|"
  "renderers/interactive-cpp/fractals-generator|https://github.com/leoraclet/fractals-generator|"
  "renderers/interactive-cpp/fractals|https://github.com/leoraclet/fractals|"
  "renderers/interactive-cpp/FractaVista|https://github.com/Krish2882005/FractaVista|"
  "renderers/deep-zoom/FractalShark|https://github.com/mattsaccount364/FractalShark|"
  "renderers/deep-zoom/MandlebrotSetSFML|https://github.com/NeKon69/MandlebrotSetSFML|"
  "renderers/deep-zoom/CUDA-FractalExplorer|https://github.com/NeKon69/CUDA-FractalExplorer|"
  "renderers/deep-zoom/kf2|https://github.com/smurfix/kf2|"
  "renderers/deep-zoom/MV2|https://github.com/Yilmaz4/MV2|"
  "renderers/deep-zoom/DeepDrill|https://github.com/dirkwhoffmann/DeepDrill|"
  "renderers/deep-zoom/GAPFixFractal|https://github.com/bernds/GAPFixFractal|"
  "renderers/rust-wgpu/Fractl|https://github.com/Shapur1234/Fractl|"
  "renderers/rust-wgpu/par-fractal|https://github.com/paulrobello/par-fractal|"

  # Mature desktop explorers and historical lineages.
  "desktop-classics/XaoS|https://github.com/xaos-project/XaoS|"
  "desktop-classics/gnofract4d|https://github.com/fract4d/gnofract4d|"
  "desktop-classics/fraqtive|https://github.com/mimecorg/fraqtive|"
  "desktop-classics/iterated-dynamics|https://github.com/LegalizeAdulthood/iterated-dynamics|"
  "desktop-classics/manpwin|https://github.com/PaulTheLionHeart/manpwin|"
  "desktop-classics/fractorium|https://github.com/mfeemster/fractorium|"
  "desktop-classics/Fragmentarium|https://github.com/Syntopia/Fragmentarium|"
  "desktop-classics/FragM|https://github.com/3Dickulus/FragM|"
  "desktop-classics/fractalnow|https://github.com/LegalizeAdulthood/fractalnow|"
  "desktop-classics/fractint|https://github.com/LegalizeAdulthood/fractint|"
  "desktop-classics/fractint-legacy|https://github.com/LegalizeAdulthood/fractint-legacy|"
  "formula-catalogs/fract4d-formulas|https://github.com/fract4d/formulas|"

  # Browser-native, WebGL, WebGPU, and WASM explorers.
  "browser-webgpu/mandelbrot-maps|https://github.com/JMaio/mandelbrot-maps|"
  "browser-webgpu/FractalLab-zz85|https://github.com/zz85/FractalLab|"
  "browser-webgpu/FragmentariumWeb|https://github.com/Syntopia/FragmentariumWeb|"
  "browser-webgpu/Fractr|https://github.com/Shinigami92/Fractr|"
  "browser-webgpu/FractalAI|https://github.com/Nooshu/FractalAI|"
  "browser-webgpu/webgl-fractal-explorer|https://github.com/ikelaiah/webgl-fractal-explorer|"
  "browser-webgpu/multibrot-set|https://github.com/Xhst/multibrot-set|"
  "browser-webgpu/mandelbrot-js|https://github.com/cslarsen/mandelbrot-js|"
  "browser-webgpu/mandelbrot-wasm-rust-rayon|https://github.com/Ngalstyan4/mandelbrot-wasm-rust-rayon|"
  "browser-webgpu/GMT-fractals|https://github.com/gamazama/GMT-fractals|"
  "browser-webgpu/fractos|https://github.com/fractos/fractos|"
  "browser-webgpu/wasm-mandelbrot|https://github.com/ColinEberhardt/wasm-mandelbrot|"
  "browser-webgpu/magnetic-fractals-rust-wasm|https://github.com/leungjch/magnetic-fractals-rust-wasm|"
  "browser-webgpu/webgpu-fractal|https://github.com/thaapasa/webgpu-fractal|"
  "browser-webgpu/YetAnotherFractalExplorer|https://github.com/0xAdriaTorralba/YetAnotherFractalExplorer|"
  "browser-webgpu/fractals-js|https://github.com/mimecuvalo/fractals-js|"
  "browser-webgpu/davidbau-mandelbrot|https://github.com/davidbau/mandelbrot|"

  # Deep zoom, precision, and rendering cores.
  "deep-zoom/rust-fractal-core|https://github.com/rust-fractal/rust-fractal-core|"
  "deep-zoom/rust-fractal-gui|https://github.com/rust-fractal/rust-fractal-gui|"
  "deep-zoom/nanobrot|https://github.com/flutomax/nanobrot|"
  "deep-zoom/FractalSharp|https://github.com/IsaMorphic/FractalSharp|"
  "deep-zoom/rsfrac|https://github.com/SkwalExe/rsfrac|"

  # Flame fractals and IFS systems.
  "flames-ifs/flam3|https://github.com/scottdraves/flam3|"
  "flames-ifs/fr0st|https://github.com/gijzelaerr/fr0st|"
  "flames-ifs/qosmic|https://github.com/bitsed/qosmic|"
  "flames-ifs/flamelet|https://github.com/AstridFox/flamelet|"
  "flames-ifs/flame-fractal-renderer|https://github.com/tkoz0/flame-fractal-renderer|"
  "flames-ifs/IFS-Fractals|https://github.com/jonas-lj/IFS-Fractals|"
  "flames-ifs/FLAM3_for_SideFX_Houdini|https://github.com/alexnardini/FLAM3_for_SideFX_Houdini|"
  "flames-ifs/IFSRenderer|https://github.com/bezo97/IFSRenderer|"

  # L-systems, Newton, Lyapunov, Buddhabrot, Julia-language math, and other specialized references.
  "specialized/l-system-drawing|https://github.com/ambron60/l-system-drawing|"
  "specialized/ProceduralTreeGeneration|https://github.com/AaryaDevnani/ProceduralTreeGeneration|"
  "specialized/Newton-Fractals|https://github.com/makspll/Newton-Fractals|"
  "specialized/newton-fractals-seodecre|https://github.com/SeoDecre/newton-fractals|"
  "specialized/lyapunov|https://github.com/RokerHRO/lyapunov|"
  "specialized/fractal-generator-maxbrodeur|https://github.com/maxbrodeur/fractal-generator|"
  "specialized/cudabrot|https://github.com/yalue/cudabrot|"
  "specialized/Fractal_Buddhabrot|https://github.com/joaocarvalhoopen/Fractal_Buddhabrot|"
  "specialized/Fatou.jl|https://github.com/chakravala/Fatou.jl|"
  "specialized/FractalDimensions.jl|https://github.com/JuliaDynamics/FractalDimensions.jl|"
  "specialized/julia-fractal-optimization|https://github.com/ibanlegi/julia-fractal-optimization|"
  "specialized/jfx-fractal|https://github.com/wswright/jfx-fractal|"
  "specialized/fractal_generator-xtrinch|https://github.com/xtrinch/fractal_generator|"
  "specialized/ChaosGame|https://github.com/TheodorUtvik/ChaosGame|"
  "specialized/FractalLab-jtcass01|https://github.com/jtcass01/FractalLab|"

  # Small CLI/reference implementations and language-concurrency benchmarks.
  "cli-small/gobrot|https://github.com/esimov/gobrot|"
  "cli-small/asciibrot|https://github.com/esimov/asciibrot|"
  "cli-small/geomandel|https://github.com/crapp/geomandel|"
  "cli-small/gomandel|https://github.com/nsf/gomandel|"
  "cli-small/MandelbrotGoLang|https://github.com/albertnadal/MandelbrotGoLang|"
  "cli-small/mandelbrot-go|https://github.com/sverrirab/mandelbrot-go|"
  "cli-small/fractals-cli|https://github.com/MicheleFiladelfia/fractals-cli|"
  "cli-small/ProgrammingRust-mandelbrot|https://github.com/ProgrammingRust/mandelbrot|"
  "cli-small/rust_mandelbrot|https://github.com/msinilo/rust_mandelbrot|"
  "cli-small/haskell-fractal|https://github.com/cies/haskell-fractal|"

  # Apple/Metal and mobile references.
  "apple-metal/ShaderMania|https://github.com/markusmoenig/ShaderMania|"
  "apple-metal/RealityKit-Terrain-Shader|https://github.com/Misfits-Rebels-Outcasts/RealityKit-Terrain-Shader|"
  "mobile/Puzzaks-fractals|https://github.com/Puzzaks/fractals|"
  "mobile/mandelbrot-fractal-generator|https://github.com/MathBunny/mandelbrot-fractal-generator|"

  # Large/optional support reference.
  "research-toolkits/Psychtoolbox-3|https://github.com/Psychtoolbox-3/Psychtoolbox-3|optional-large"
)

DEAD_OR_UNRESOLVED=(
  "https://github.com/rafael-fuente/NumbaShader"
  "https://github.com/s-macke/par-fractal"
  "Fract Android repository from the prose note: unresolved exact GitHub URL"
)

category_of() {
  local dest="$1"
  printf '%s\n' "${dest%%/*}"
}

list_categories() {
  local entry dest _url _flags
  for entry in "${REPOS[@]}"; do
    IFS='|' read -r dest _url _flags <<<"$entry"
    category_of "$dest"
  done | sort -u
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
      TARGET_DIR="$2"
      shift 2
      ;;
    --category)
      [[ $# -ge 2 ]] || { echo "Missing value for --category" >&2; exit 2; }
      CATEGORY_FILTER="$2"
      shift 2
      ;;
    --with-large|--with-psych)
      INCLUDE_LARGE=1
      shift
      ;;
    --full)
      FULL_HISTORY=1
      shift
      ;;
    --update)
      UPDATE_EXISTING=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --verify)
      VERIFY_ONLY=1
      shift
      ;;
    --list-categories)
      list_categories
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [[ -n "$CATEGORY_FILTER" ]] && ! list_categories | grep -qx -- "$CATEGORY_FILTER"; then
  echo "Unknown category: $CATEGORY_FILTER" >&2
  echo "Available categories:" >&2
  list_categories >&2
  exit 2
fi

clone_args=()
if [[ "$FULL_HISTORY" -eq 0 ]]; then
  clone_args+=(--depth 1)
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

success=()
skipped=()
failed=()
verified=()

for entry in "${REPOS[@]}"; do
  IFS='|' read -r dest url flags <<<"$entry"
  category="$(category_of "$dest")"

  if [[ -n "$CATEGORY_FILTER" && "$category" != "$CATEGORY_FILTER" ]]; then
    continue
  fi

  if [[ "$flags" == *optional-large* && "$INCLUDE_LARGE" -eq 0 ]]; then
    skipped+=("$dest (optional large; pass --with-large)")
    continue
  fi

  target_path="$TARGET_DIR/$dest"

  if [[ "$VERIFY_ONLY" -eq 1 ]]; then
    printf 'Verifying %-45s %s\n' "$dest" "$url"
    if git ls-remote --heads "$url" >/dev/null 2>&1; then
      verified+=("$dest")
    else
      failed+=("$url")
    fi
    continue
  fi

  if [[ -d "$target_path/.git" ]]; then
    if [[ "$UPDATE_EXISTING" -eq 1 ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "DRY-RUN update $dest"
        skipped+=("$dest (dry-run update)")
      else
        echo "Updating $dest"
        if git -C "$target_path" pull --ff-only; then
          success+=("$dest (updated)")
        else
          failed+=("$url")
        fi
      fi
    else
      echo "Skipping $dest (already exists)"
      skipped+=("$dest (already exists)")
    fi
    continue
  fi

  if [[ -e "$target_path" ]]; then
    echo "Skipping $dest (path exists but is not a git repo)"
    skipped+=("$dest (non-git path exists)")
    continue
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY-RUN clone ${clone_args[*]} $url -> $dest"
    skipped+=("$dest (dry-run clone)")
    continue
  fi

  echo "Cloning $url -> $dest"
  mkdir -p "$(dirname "$target_path")"
  if git clone "${clone_args[@]}" "$url" "$target_path"; then
    success+=("$dest")
  else
    failed+=("$url")
  fi
done

echo
echo "========== SUMMARY =========="
if [[ "$VERIFY_ONLY" -eq 1 ]]; then
  echo "Reachable remotes: ${#verified[@]}"
else
  echo "Success: ${#success[@]}"
fi
echo "Skipped: ${#skipped[@]}"
echo "Failed: ${#failed[@]}"

if [[ ${#success[@]} -gt 0 ]]; then
  echo
  echo "Success entries:"
  printf '  %s\n' "${success[@]}"
fi

if [[ ${#verified[@]} -gt 0 ]]; then
  echo
  echo "Verified entries:"
  printf '  %s\n' "${verified[@]}"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
  echo
  echo "Skipped entries:"
  printf '  %s\n' "${skipped[@]}"
fi

if [[ ${#failed[@]} -gt 0 ]]; then
  echo
  echo "Failed remotes:"
  printf '  %s\n' "${failed[@]}"
  echo
  echo "Known dead/unresolved references kept out of the clone list:"
  printf '  %s\n' "${DEAD_OR_UNRESOLVED[@]}"
  exit 1
fi

echo
echo "Done. Study patterns freely; copy code only after license review."
