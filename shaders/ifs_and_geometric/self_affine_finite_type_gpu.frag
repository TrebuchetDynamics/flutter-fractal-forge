#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uDepth;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 p=(fc-.5*uResolution)/max(1.0,sc)/max(uZoom,1e-6)+uCenter;int depth=int(clamp(uDepth,2.0,16.0));float trap=1e3;vec2 q=p;for(int i=0;i<16;i++){if(i>=depth)break;q=abs(mat2(1.25,.35,-.18,.82)*q)-vec2(.35,.22);trap=min(trap,length(q)/pow(1.25,float(i)));}float ink=smoothstep(.04,0.0,trap);vec3 col=mix(vec3(.02,.02,.035),vec3(.85,.42,.95),ink);fragColor=vec4(linearToSRGB(col),1.0);}
