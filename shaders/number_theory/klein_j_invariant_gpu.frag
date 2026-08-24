#include <flutter/runtime_effect.glsl>
precision highp float;

// Klein modular invariant from finite q-series: j(tau)=E4(tau)^3/Delta(tau),
// E4=1+240 sum sigma_3(n)q^n and Delta=q prod(1-q^n)^24.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg; uniform float uMode;
out vec4 fragColor;
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec2 cdiv(vec2 a,vec2 b){float d=max(dot(b,b),1e-24);return vec2(a.x*b.x+a.y*b.y,a.y*b.x-a.x*b.y)/d;}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.07*k,.35+.03*k,.69+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
float sigma3(int n){float s=0.0;for(int d=1;d<=24;d++){if(d>n)break;int q=n/d;if(n-q*d==0)s+=float(d*d*d);}return s;}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 uv=(fc-.5*uResolution)/size;vec2 tau=vec2(uv.x*2.0/max(uZoom,.001)+uCenter.x,max(.025,uv.y*1.6/max(uZoom,.001)+uCenter.y));float qm=exp(-6.283185*tau.y);vec2 q=qm*vec2(cos(6.283185*tau.x),sin(6.283185*tau.x));vec2 qn=vec2(1,0),e4=vec2(1,0),prod=vec2(1,0);int terms=int(clamp(uIterations,6.0,24.0));for(int n=1;n<=24;n++){if(n>terms)break;qn=cmul(qn,q);e4+=240.0*sigma3(n)*qn;vec2 f=vec2(1.0,0.0)-qn;vec2 f24=vec2(1,0);for(int k=0;k<24;k++)f24=cmul(f24,f);prod=cmul(prod,f24);}vec2 delta=cmul(q,prod);vec2 j=cdiv(cmul(cmul(e4,e4),e4),delta);float mag=length(j),arg=atan(j.y,j.x)/6.283185;int mode=int(clamp(floor(uMode+.5),0.0,2.0));float domain=max(abs(tau.x)-.5,1.0-length(tau));float edge=1.0-smoothstep(0.0,.025,abs(domain));float t=mode==0?fract(log(1.0+mag)/8.0):mode==1?fract(arg+1.0):fract(log(1.0+mag)/5.0+.25*arg);vec3 col=pal(t,uColorScheme);if(mode==2)col=mix(col,vec3(1),edge);fragColor=vec4(srgb(col),uTransparentBg>.5?.92:1.0);}
