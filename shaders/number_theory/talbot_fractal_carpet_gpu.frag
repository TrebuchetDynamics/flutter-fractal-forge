#include <flutter/runtime_effect.glsl>
precision highp float;

// Berry-Klein Talbot carpet. Fresnel propagation of a periodic grating is the
// bounded Fourier sum U(X,Z)=sum a_m exp(i*2pi*(mX-m^2 Z)).
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uAperture; uniform float uMode;
out vec4 fragColor;
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.08*k,.35+.03*k,.69+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 p=(fc-.5*uResolution)/size/max(uZoom,.001)+uCenter;float x=p.x,z=p.y;int orders=int(clamp(uIterations,4.0,48.0));float ap=clamp(uAperture,.1,1.0);vec2 u=vec2(ap,0.0);for(int m=-48;m<=48;m++){if((m<0?-m:m)>orders||m==0)continue;float mf=float(m);float coeff=sin(3.14159265*mf*ap)/(3.14159265*mf);float phase=6.283185*(mf*x-mf*mf*z);u+=coeff*vec2(cos(phase),sin(phase));}float intensity=dot(u,u),phase=atan(u.y,u.x)/6.283185;int mode=int(clamp(floor(uMode+.5),0.0,2.0));float t=mode==0?fract(intensity*.24):mode==1?fract(phase+1.0):fract(log(1.0+intensity)*.7+phase*.2);vec3 col=pal(t,uColorScheme)*(mode==1?.85:clamp(.25+.45*log(1.0+intensity),.2,1.0));fragColor=vec4(srgb(col),uTransparentBg>.5?clamp(.15+intensity*.2,.15,1.0):1.0);}
