#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  return mix(1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055,
    lin * 12.92, vec3(lessThan(lin, vec3(0.0031308))));
}
// Same procedural 0..49 palettes and 50..63 relief semantics as Multibrot.
vec3 palette(float t, int scheme) {
  if (scheme == 0) return .5+.5*cos(6.28318*(t+vec3(0,.4,.7)));
  if (scheme == 1) return .5+.5*cos(6.28318*(t+vec3(.5,.3,0)));
  if (scheme == 2) return .5+.5*cos(6.28318*(t+vec3(0,.33,.67)));
  if (scheme == 3) return vec3(.5+.5*cos(6.28318*t));
  float s = float(scheme);
  vec3 a = .55+.15*sin(vec3(1,2,3)*(.37*s+.1));
  vec3 b = .45+.25*cos(vec3(1.7,2.3,2.9)*(.29*s+.2));
  vec3 c = 1.0+.80*sin(vec3(.8,1.3,1.7)*(.11*s+.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719)*(s+.5))*43758.5453);
  return clamp(a+b*cos(6.28318*(c*t+d)),0.0,1.0);
}
vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x); }
bool finiteValue(float x) { return x == x && abs(x) <= 3.0e38; }
float valid(float x, float fallback) { return finiteValue(x) ? x : fallback; }
float magnitude(vec2 v) {
  float m = max(abs(v.x),abs(v.y));
  return m == 0.0 ? 0.0 : m * length(v/m);
}
float logMagnitude(vec2 v) {
  float m = max(abs(v.x),abs(v.y));
  return log(max(m,1e-30)) + log(length(m > 0.0 ? v/m : vec2(1.0,0.0)));
}
void main() {
  vec2 resolution = vec2(max(1.0,valid(uResolution.x,1.0)), max(1.0,valid(uResolution.y,1.0)));
  float zoom = clamp(valid(uZoom,.4),1e-9,1e12);
  vec2 center = vec2(valid(uCenter.x,-.35),valid(uCenter.y,0.0));
  vec2 c = (FlutterFragCoord().xy-.5*resolution)/min(resolution.x,resolution.y)/zoom+center;
  // Legal UI bailout is 2..8; normalize malformed saved/unbound uniforms.
  float bailout = clamp(valid(uBailout,4.0),2.0,8.0);
  float radius = max(max(2.0,pow(12.0,1.0/3.0)),
      max(bailout,exp((logMagnitude(c)+log(4.0))/5.0)));
  radius *= 1.00001; // Conservative rounding margin; not a precision guarantee.
  const int MAX_ITERS = 500;
  int target = int(clamp(valid(uIterations,400.0),0.0,float(MAX_ITERS)));
  int scheme = int(clamp(valid(uColorScheme,1.0),0.0,63.0));
  vec2 z = vec2(0.0), der = vec2(0.0);
  float logDer = 0.0;
  bool escape = false;
  int count = 0;
  float trap = 1e9, glow = 0.0;
  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;
    // The previous update was tested before any further large powers.
    vec2 z2 = cmul(z,z), z3 = cmul(z2,z), z4 = cmul(z2,z2);
    vec2 factor = 5.0*z4+3.0*z2+6.0*z;
    // Scaled complex derivative: D=der*exp(logDer); prevent long-orbit overflow.
    float base = max(logDer,0.0);
    vec2 nextDer = cmul(factor,der)*exp(min(logDer,0.0))+vec2(exp(-base),0.0);
    float dm = magnitude(nextDer);
    der = dm > 0.0 ? nextDer/dm : vec2(0.0);
    logDer = dm > 0.0 ? base+log(dm) : 0.0;
    z = cmul(z3,z2)+z3+3.0*z2+c;
    count = j+1;
    float r = magnitude(z);
    trap = min(trap,abs(r-.75));
    glow += exp(-4.0*min(r*r,100.0));
    if (logMagnitude(z) > log(radius)) { escape = true; break; }
  }
  if (!escape) {
    if (valid(uTransparentBg,0.0) > .5) { fragColor=vec4(0.0); return; }
    float t = fract(-log(max(1e-8,trap))*.18+glow*.07+5.0*.013);
    fragColor=vec4(linearToSRGB(palette(t,scheme)*(.35+.45*t)),1.0);
    return;
  }
  float smoothVal = float(count)+1.0-log(max(1e-12,max(logMagnitude(z),0.0)))/log(5.0);
  float t = fract(smoothVal/64.0);
  vec3 color;
  if (scheme >= 50) {
    // Only the direction of z/D is needed; normalized factors avoid overflow.
    vec2 zn = z/max(max(abs(z.x),abs(z.y)),1e-30);
    zn /= max(length(zn),1e-30);
    vec2 nv = vec2(dot(zn,der),zn.y*der.x-zn.x*der.y);
    float nl = magnitude(nv);
    nv = nl > 1e-12 ? nv/nl : vec2(0.0);
    float angle = float(scheme-50)*(3.14159265/13.0);
    float light = pow(clamp((dot(nv,vec2(cos(angle),sin(angle)))+.5)/1.5,0.0,1.0),1.0/1.8);
    color = palette(t,(scheme-50)-((scheme-50)/4)*4)*light;
  } else color = palette(t,scheme);
  fragColor=vec4(linearToSRGB(color),1.0);
}
