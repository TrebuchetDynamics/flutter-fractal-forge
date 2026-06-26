#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uThreshold; uniform float uRefractoryPeriod; uniform float uCurvatureWeight; uniform float uDispersion;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
float h(vec2 p){return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453);}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 uv=(fc-.5*uResolution)/max(1.0,sc);vec2 p=uv/max(uZoom,1e-6)+uCenter;vec2 cell=floor(p*70.0);float wave=sin(length(p)*22.0-uTime*.01+uDispersion*sin(p.x*8.0));float curve=cos(atan(p.y,p.x)*5.0+uCurvatureWeight*length(p)*8.0);float excited=smoothstep(.35,.8,wave+0.35*curve+h(cell)*.25);float refr=fract(h(cell)+uTime*.0005+uIterations/max(2.0,uRefractoryPeriod));vec3 col=mix(vec3(.02,.02,.04),vec3(.95,.72,.18),excited);col=mix(col,vec3(.18,.38,.95),smoothstep(.3,.9,refr)*(1.0-excited));fragColor=vec4(linearToSRGB(col),1.0);}
