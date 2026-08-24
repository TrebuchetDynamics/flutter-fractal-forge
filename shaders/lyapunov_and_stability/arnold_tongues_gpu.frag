#include <flutter/runtime_effect.glsl>
precision highp float;

// Arnold circle map parameter plane:
// x_(n+1)=x_n+Omega-K/(2pi) sin(2pi x_n) (mod 1).
// Plateaus of rational rotation number form the phase-locking tongues.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg; uniform float uMode;
out vec4 fragColor;
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.09*k,.33+.02*k,.66+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 p=(fc-.5*uResolution)/size/max(uZoom,.001)+uCenter;float omega=clamp(p.x,0.0,1.0),k=clamp(p.y*2.0,0.0,2.5);int cap=int(clamp(uIterations,40.0,240.0));float x=.173,unwrapped=0.0,lyap=0.0;for(int i=0;i<240;i++){if(i>=cap)break;float stepv=omega-k/6.283185*sin(6.283185*x);x=fract(x+stepv);if(i>19)unwrapped+=stepv;lyap+=log(max(1e-6,abs(1.0-k*cos(6.283185*x))));}float rot=unwrapped/max(1.0,float(cap-20));float lock=1.0;float denom=1.0;for(int q=1;q<=12;q++){for(int n=0;n<=12;n++){if(n>q)break;float d=abs(rot-float(n)/float(q));if(d<lock){lock=d;denom=float(q);}}}float tongue=exp(-220.0*lock*denom);int mode=int(clamp(floor(uMode+.5),0.0,2.0));float t=mode==0?fract(rot):mode==1?fract(log(1.0+denom)*.37):fract(.5+.16*lyap/float(cap));vec3 col=pal(t,uColorScheme);if(mode<2)col=mix(col*.22,col,tongue);else col*=clamp(.35+.45*lyap/float(cap)+.5,0.1,1.0);fragColor=vec4(srgb(col),uTransparentBg>.5?clamp(.25+tongue,.25,1.0):1.0);}
