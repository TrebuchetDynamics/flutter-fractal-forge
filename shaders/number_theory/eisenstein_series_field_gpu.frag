#include <flutter/runtime_effect.glsl>
precision highp float;

// Modular Eisenstein fields E4 and E6 from their q-expansions:
// E4=1+240 sum sigma3(n)q^n; E6=1-504 sum sigma5(n)q^n.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uWeight; uniform float uMode;
out vec4 fragColor;
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.08*k,.37+.02*k,.7+.03*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
float sigmaPow(int n,int power){float s=0.0;for(int d=1;d<=24;d++){if(d>n)break;int q=n/d;if(n-q*d==0){float x=float(d);s+=power==3?x*x*x:x*x*x*x*x;}}return s;}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 uv=(fc-.5*uResolution)/size;vec2 tau=vec2(uv.x*2.0/max(uZoom,.001)+uCenter.x,max(.025,uv.y*1.6/max(uZoom,.001)+uCenter.y));float qm=exp(-6.283185*tau.y);vec2 q=qm*vec2(cos(6.283185*tau.x),sin(6.283185*tau.x)),qn=vec2(1,0),e=vec2(1,0);int weight=int(floor(uWeight+.5));int terms=int(clamp(uIterations,6.0,24.0));for(int n=1;n<=24;n++){if(n>terms)break;qn=cmul(qn,q);e+=(weight<5?240.0:-504.0)*sigmaPow(n,weight<5?3:5)*qn;}float mag=length(e),arg=atan(e.y,e.x)/6.283185;int mode=int(clamp(floor(uMode+.5),0.0,2.0));float contour=1.0-smoothstep(.0,.05,abs(fract(log(1.0+mag)*3.0)-.5));float t=mode==0?fract(log(1.0+mag)):mode==1?fract(arg+1.0):fract(arg+.3*log(1.0+mag));vec3 col=pal(t,uColorScheme);if(mode==2)col=mix(col,vec3(1),.55*contour);fragColor=vec4(srgb(col),uTransparentBg>.5?.9:1.0);}
