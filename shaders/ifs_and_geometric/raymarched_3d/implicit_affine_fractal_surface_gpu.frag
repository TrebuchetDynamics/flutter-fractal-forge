#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uEpsilon;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
float de(vec3 p){float s=1.0;for(int i=0;i<12;i++){p=abs(p);if(p.x<p.y)p.xy=p.yx;if(p.x<p.z)p.xz=p.zx;p=p*1.7-vec3(.55,.35,.25);s*=1.7;}return length(p)/s;}
void main(){vec2 fc=FlutterFragCoord().xy;vec2 uv=(fc-.5*uResolution)*2.0/uResolution.y;vec3 ro=vec3(0,0,3.0/max(uZoom,.2));vec3 rd=normalize(vec3(uv,-1.4));float t=0.0;float hit=-1.0;for(int i=0;i<128;i++){vec3 p=ro+rd*t;float d=de(p);if(d<uEpsilon){hit=float(i);break;}t+=d*.8;if(t>12.0)break;}vec3 col=hit<0.0?vec3(.02,.025,.04):(.5+.5*cos(6.28318*(hit/80.0+vec3(0,.33,.67))));fragColor=vec4(linearToSRGB(col),1.0);}
