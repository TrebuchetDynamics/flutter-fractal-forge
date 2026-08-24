#include <flutter/runtime_effect.glsl>
precision highp float;

// Julia field for the q-exponential e_q(z)=sum z^n/[n]_q!, with
// [n]_q=(1-q^n)/(1-q). The finite 14-term series is stable and interactive.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uQ; uniform float uCReal; uniform float uCImag;
out vec4 fragColor;
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec2 qexpf(vec2 z,float q){vec2 term=vec2(1.0,0.0),sum=term;float qn=1.0,fact=1.0;for(int n=1;n<=14;n++){qn*=q;float qnum=abs(1.0-q)<.001?float(n):(1.0-qn)/(1.0-q);fact*=max(.02,abs(qnum));term=cmul(term,z);sum+=term/fact;}return sum;}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.08*k,.36+.02*k,.7+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 z=(fc-.5*uResolution)/size*3.0/max(uZoom,.001)+uCenter;vec2 c=vec2(uCReal,uCImag);int cap=int(clamp(uIterations,12.0,180.0));int hit=cap;float trap=10.0;for(int i=0;i<180;i++){if(i>=cap)break;z=.42*qexpf(z,clamp(uQ,.1,1.4))+c;trap=min(trap,abs(z.x)+abs(z.y));if(dot(z,z)>max(4.0,uBailout*uBailout)){hit=i+1;break;}}float t=fract(float(hit)/32.0+.18/(.04+trap)+atan(z.y,z.x)/12.566);vec3 col=hit==cap?vec3(.01,.025,.035)+.15*pal(fract(trap),uColorScheme):pal(t,uColorScheme);fragColor=vec4(srgb(col),uTransparentBg>.5?(hit==cap?.35:1.0):1.0);}
