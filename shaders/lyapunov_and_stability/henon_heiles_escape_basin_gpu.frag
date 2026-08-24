#include <flutter/runtime_effect.glsl>
precision highp float;

// Hénon-Heiles Hamiltonian escape basins above E=1/6:
// H=(px^2+py^2+x^2+y^2)/2+x^2*y-y^3/3. A leapfrog section is colored by
// which of the three exits captures the orbit; basin boundaries are fractal.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uEnergy; uniform float uStepSize;
out vec4 fragColor;
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.09*k,.34+.03*k,.68+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
vec2 gradV(vec2 r){return vec2(r.x+2.0*r.x*r.y,r.y+r.x*r.x-r.y*r.y);}
float potential(vec2 r){return .5*dot(r,r)+r.x*r.x*r.y-r.y*r.y*r.y/3.0;}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 r=(fc-.5*uResolution)/size*2.6/max(uZoom,.001)+uCenter;float e=clamp(uEnergy,.17,.5),v=potential(r);if(v>=e){fragColor=vec4(srgb(vec3(.006,.01,.02)),uTransparentBg>.5?0.08:1.0);return;}vec2 mom=vec2(sqrt(max(0.0,2.0*(e-v))),0.0);float dt=clamp(uStepSize,.002,.03);int cap=int(clamp(uIterations,30.0,240.0));int hit=cap,exitId=0;float close=10.0;for(int i=0;i<240;i++){if(i>=cap)break;mom-=.5*dt*gradV(r);r+=dt*mom;mom-=.5*dt*gradV(r);close=min(close,abs(potential(r)-1.0/6.0));if(length(r)>max(1.7,uBailout*.55)){hit=i+1;float a=atan(r.y,r.x);exitId=a>1.047?0:(a< -1.047?1:2);break;}}float t=fract(float(exitId)/3.0+.22*float(hit)/float(cap));vec3 col=hit==cap?vec3(.012,.02,.035)+.12*pal(fract(close*8.0),uColorScheme):pal(t,uColorScheme)*(.45+.55*float(hit)/float(cap));fragColor=vec4(srgb(col),uTransparentBg>.5?(hit==cap?.3:1.0):1.0);}
