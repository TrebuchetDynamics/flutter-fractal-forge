# Source inventory and licensing boundary

## User-supplied lead

- Reddit post text: **“Deforum, SDXL, spiders and such”** in `r/Fractalish`, supplied directly in the task. The visible prompt schedule changes subject nouns at frames 0/1000/2000/3000/4000 while retaining a common “intricate colorful fractal” style and one LoRA reference.
- Rights status of the post, video, generated frames, model outputs, and named LoRA: **unknown**.
- Boundary: no frame, image, prompt string, checkpoint, LoRA, Reddit asset, or derived texture is bundled or reproduced.

## OSS reference

- [Deforum for Stable Diffusion WebUI](https://github.com/deforum/sd-webui-deforum): public implementation and documentation of animation settings, prompt schedules, and mathematical keyframing. Repository license shown by GitHub is GNU AGPL-3.0.
- Boundary: architecture-level observation only. No Deforum source code or dependency is copied, linked, translated, or imported.

## Retrieved scholarly metadata leads

- *Video Diffusion Models: A Survey* (2024), DOI `10.48550/arxiv.2405.03150`.
- *LAVIE: High-Quality Video Generation with Cascaded Latent Diffusion Models* (2023), DOI `10.48550/arxiv.2309.15103`.
- *Estimating optical flow: A comprehensive review of the state of the art* (2024), DOI `10.1016/j.cviu.2024.104160`.
- *Diffusion as Shader: 3D-aware Video Diffusion for Versatile Video Generation Control* (2025), DOI `10.1145/3721238.3730607`.
- *Spider webs inspiring soft robotics* (2020), DOI `10.1098/rsif.2020.0569`.
- *Fast Simulation Method for Ocean Wave Base on Ocean Wave Spectrum and Improved Gerstner Model with GPU* (2017), DOI `10.1088/1742-6596/787/1/012027`.

These records were used only to anchor broad design themes visible in titles/metadata: temporal coherence, keyframes, radial web networks, and layered GPU wave synthesis. No full text was acquired and no scientific performance claim is made.

## Production boundary

The implementation is an original Flutter runtime-effect GLSL program. It uses analytic shapes, dihedral folding, logarithmic rings, fixed-seed value noise/fBm, recursive signed-distance frames, orbit-trap texture, layered sine waves, and Hermite interpolation. It has no sampler, model inference, network access, third-party binary, or third-party media.
