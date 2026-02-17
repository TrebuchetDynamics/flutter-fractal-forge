// Shared palette sampling — include in escape-time shaders.
// Requires: uniform sampler2D uPalette;
vec3 samplePalette(float t) {
  return texture(uPalette, vec2(clamp(t, 0.0, 1.0), 0.5)).rgb;
}
