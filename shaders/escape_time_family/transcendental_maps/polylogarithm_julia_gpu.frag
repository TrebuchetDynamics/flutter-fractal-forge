#include <flutter/runtime_effect.glsl>
precision highp float;

// Julia iteration of a finite polylogarithm series:
// Li_s(z)=sum_{n>=1} z^n/n^s, evaluated with 12 terms for a stable GPU field.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uOrder; uniform float uCReal; uniform float uCImag;
out vec4 fragColor;
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec2 polylog(vec2 z,float s){vec2 p=z,sum=vec2(0.0);for(int n=1;n<=12;n++){sum+=p/pow(float(n),s);p=cmul(p,z);}return sum;}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.1*k,.31+.03*k,.64+.05*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 z=(fc-.5*uResolution)/size*3.2/max(uZoom,.001)+uCenter;vec2 c=vec2(uCReal,uCImag);int cap=int(clamp(uIterations,12.0,180.0));int hit=cap;float trap=10.0;for(int i=0;i<180;i++){if(i>=cap)break;z=.72*polylog(z,clamp(uOrder,1.0,4.0))+c;trap=min(trap,length(z-vec2(.25,0.0)));if(dot(z,z)>max(4.0,uBailout*uBailout)){hit=i+1;break;}}float smoothVal=float(hit)-log2(log2(max(2.0,dot(z,z))));float t=fract(smoothVal/32.0+.14/(.03+trap));vec3 col=hit==cap?vec3(.018,.012,.035)+.18*pal(fract(trap),uColorScheme):pal(t,uColorScheme);fragColor=vec4(srgb(col),uTransparentBg>.5?(hit==cap?.35:1.0):1.0);}
