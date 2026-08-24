#include <flutter/runtime_effect.glsl>
precision highp float;

// Jacobi theta-function field using the defining Fourier series for theta2,
// theta3, and theta4 (NIST DLMF Chapter 20), truncated at 24 terms.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uNome; uniform float uFamily; uniform float uMode;
out vec4 fragColor;
vec2 ccos(vec2 z){return vec2(cos(z.x)*cosh(z.y),-sin(z.x)*sinh(z.y));}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.09*k,.32+.02*k,.66+.05*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 z=(fc-.5*uResolution)/size*5.0/max(uZoom,.001)+uCenter;float q=clamp(uNome,.05,.92);int family=int(clamp(floor(uFamily+.5),2.0,4.0));int terms=int(clamp(uIterations,4.0,24.0));vec2 theta=family==2?vec2(0):vec2(1,0);for(int n=0;n<24;n++){if(n>=terms)break;float nf=float(n);if(family==2){float h=nf+.5;theta+=2.0*pow(q,h*h)*ccos((2.0*nf+1.0)*z);}else{if(n==0)continue;float signv=(family==4 && n-(n/2)*2==1)?-1.0:1.0;theta+=2.0*signv*pow(q,nf*nf)*ccos(2.0*nf*z);}}float mag=length(theta),arg=atan(theta.y,theta.x)/6.283185;int mode=int(clamp(floor(uMode+.5),0.0,2.0));float zeroBand=exp(-8.0*mag);float t=mode==0?fract(log(1.0+mag)*.7):mode==1?fract(arg+1.0):fract(arg+.25*log(1.0+mag));vec3 col=pal(t,uColorScheme);if(mode==2)col=mix(col,vec3(1),zeroBand);fragColor=vec4(srgb(col),uTransparentBg>.5?clamp(.35+mag,.35,1.0):1.0);}
