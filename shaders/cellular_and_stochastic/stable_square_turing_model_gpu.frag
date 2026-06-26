#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uDiffusionU; uniform float uDiffusionV;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 p=(fc-.5*uResolution)/max(1.0,sc)/max(uZoom,1e-6)+uCenter;float squares=cos(28.0*p.x)*cos(28.0*p.y);float osc=sin(16.0*(p.x+p.y)+uTime*.002);float u=smoothstep(.1,.8,squares+0.35*osc+uDiffusionU);vec3 col=mix(vec3(.02,.025,.04),vec3(.2,.75,.95),u);col+=vec3(.7,.4,.1)*smoothstep(.7,1.0,abs(squares));fragColor=vec4(linearToSRGB(col),1.0);}
