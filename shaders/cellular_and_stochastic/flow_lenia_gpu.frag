#include <flutter/runtime_effect.glsl>
precision highp float;
// Flow-Lenia approximation with mass-conservative flow-inspired growth.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uKernelRadius; uniform float uGrowthCenter; uniform float uGrowthWidth; uniform float uDt;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float field(vec2 p){float v=0.0;for(int i=0;i<7;i++){float a=6.28318*float(i)/7.0+uTime*0.0002;vec2 c=vec2(cos(a),sin(a))*(0.18+0.06*h(vec2(float(i))));v+=exp(-dot(p-c,p-c)*24.0);}return v/7.0;}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 uv=(fc-.5*uResolution)/max(1.0,sc);vec2 p=uv/max(uZoom,1e-6)+uCenter;float a=field(p);float k=field(p+vec2(0.02,0.0))+field(p-vec2(0.02,0.0))+field(p+vec2(0.0,0.02))+field(p-vec2(0.0,0.02));k*=0.25;float growth=exp(-pow((k-uGrowthCenter)/max(0.001,uGrowthWidth),2.0))*2.0-1.0;float mass=clamp(a+uDt*growth*0.08,0.0,1.0);vec3 col=mix(vec3(0.02,0.025,0.04),vec3(0.35,0.9,0.85),smoothstep(0.1,0.7,mass));col+=0.25*vec3(0.8,0.4,1.0)*smoothstep(0.55,0.9,k);fragColor=vec4(linearToSRGB(col),1.0);}
