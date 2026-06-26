#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uR; uniform float uCoupling;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
float seed(float i){return fract(sin(i*17.17)*43758.5453);} float f(float x){return uR*x*(1.0-x);}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 uv=(fc-.5*uResolution)/max(1.0,sc);vec2 p=uv/max(uZoom,1e-6)+uCenter;float i=floor((p.x+.5)*256.0);int steps=int(clamp((p.y+.5)*uIterations,1.0,160.0));float x=seed(i),l=seed(i-1.0),r=seed(i+1.0);for(int n=0;n<160;n++){if(n>=steps)break;float nx=(1.0-uCoupling)*f(x)+0.5*uCoupling*(f(l)+f(r));l=x;x=clamp(nx,0.0,1.0);r=fract(r*1.37+0.11);}vec3 col=0.5+0.5*cos(6.28318*(x+vec3(0,.33,.67)));fragColor=vec4(linearToSRGB(col),1.0);}
