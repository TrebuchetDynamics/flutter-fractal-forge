#include <flutter/runtime_effect.glsl>
precision highp float;
// Bedford-McMullen self-affine carpet digit test on a 3x4 grid.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uDepth;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
bool allowed(int ix,int iy){return (ix==0&&iy==0)||(ix==0&&iy==1)||(ix==1&&iy==2)||(ix==2&&iy==0)||(ix==2&&iy==3);}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 uv=(fc-.5*uResolution)/max(1.0,sc);vec2 p=uv/max(uZoom,1e-6)+uCenter+vec2(0.5);int depth=int(clamp(uDepth,1.0,14.0));bool inside= p.x>=0.0&&p.x<=1.0&&p.y>=0.0&&p.y<=1.0;float edge=1.0;for(int i=0;i<14;i++){if(i>=depth||!inside)break;p.x*=3.0;p.y*=4.0;int ix=int(floor(p.x));int iy=int(floor(p.y));inside=allowed(ix,iy);vec2 f=fract(p);edge=min(edge,min(min(f.x,1.0-f.x),min(f.y,1.0-f.y))/pow(1.28,float(i)));p=f;}float ink=inside?1.0:smoothstep(0.006,0.0,edge);if(ink<0.01&&uTransparentBg>0.5){fragColor=vec4(0);return;}vec3 col=mix(vec3(0.015,0.018,0.03),vec3(0.95,0.55,0.16),ink);fragColor=vec4(linearToSRGB(col),1.0);}
