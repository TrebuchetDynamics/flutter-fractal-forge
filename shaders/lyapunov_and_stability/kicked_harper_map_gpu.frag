#include <flutter/runtime_effect.glsl>
precision highp float;

// Kicked Harper torus map (Leboeuf et al., 1990):
// p'=p+K sin(q), q'=q-L sin(p'), wrapped to the 2pi torus.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uKickX; uniform float uKickP; uniform float uMode;
out vec4 fragColor;
float wrapPi(float x){return x-6.283185*floor((x+3.14159265)/6.283185);}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.08*k,.36+.02*k,.7+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 uv=(fc-.5*uResolution)/size/max(uZoom,.001)+uCenter;float q=wrapPi(uv.x*6.283185),p=wrapPi(uv.y*6.283185),q0=q,p0=p;float k=clamp(uKickX,0.0,8.0),l=clamp(uKickP,0.0,8.0);int cap=int(clamp(uIterations,30.0,240.0));vec2 tangent=normalize(vec2(.73,.41));float lyap=0.0,rec=10.0,winding=0.0;for(int i=0;i<240;i++){if(i>=cap)break;float pp=wrapPi(p+k*sin(q));float qq=wrapPi(q-l*sin(pp));float dp=tangent.y+k*cos(q)*tangent.x;float dq=tangent.x-l*cos(pp)*dp;tangent=vec2(dq,dp);float tn=max(1e-8,length(tangent));lyap+=log(tn);tangent/=tn;q=qq;p=pp;rec=min(rec,length(vec2(wrapPi(q-q0),wrapPi(p-p0))));winding+=q;}int mode=int(clamp(floor(uMode+.5),0.0,2.0));float t=mode==0?fract(.18*lyap/float(cap)):mode==1?fract(winding/(6.283185*float(cap))):fract(.18/(.01+rec));float web=exp(-35.0*rec);vec3 col=pal(t,uColorScheme)*(.35+.65*clamp(lyap/float(cap),0.0,1.0));if(mode==2)col=mix(col,vec3(1),web);fragColor=vec4(srgb(col),uTransparentBg>.5?clamp(.25+web,.25,1.0):1.0);}
