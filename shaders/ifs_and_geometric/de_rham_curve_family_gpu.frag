#include <flutter/runtime_effect.glsl>
precision highp float;

// de Rham-type self-affine function from binary address maps. The graph obeys
// a two-branch affine functional equation and changes regularity with alpha.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uAlpha; uniform float uMode;
out vec4 fragColor;
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.08*k,.36+.03*k,.7+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
float deRham(float x,float a,int terms){float u=clamp(x,0.0,1.0),y=0.0,scale=1.0;for(int i=0;i<40;i++){if(i>=terms)break;u*=2.0;float bit=floor(u);u-=bit;if(bit<.5){y*=a;scale*=a;}else{y=a+(1.0-a)*y;scale*=1.0-a;}}return clamp(y,0.0,1.0);}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 p=(fc-.5*uResolution)/size/max(uZoom,.001)+uCenter;int terms=int(clamp(uIterations,8.0,40.0));float a=clamp(uAlpha,.08,.92),y=deRham(p.x,a,terms);float eps=1.5/size/max(uZoom,.001),yl=deRham(clamp(p.x-eps,0.0,1.0),a,terms),yr=deRham(clamp(p.x+eps,0.0,1.0),a,terms);float slope=abs(yr-yl)/(2.0*eps);int mode=int(clamp(floor(uMode+.5),0.0,2.0));float line=1.0-smoothstep(.004,.018,abs(p.y-y));float t=mode==0?fract(y*3.0):mode==1?fract(log(1.0+slope)*.45):fract(y+slope*.03);vec3 bg=pal(fract(p.x*.2+p.y*.15),uColorScheme)*.04;vec3 col=mode==2?mix(bg,pal(t,uColorScheme),clamp(exp(-4.0*abs(p.y-y))+.25*fract(slope),0.0,1.0)):mix(bg,pal(t,uColorScheme),line);fragColor=vec4(srgb(col),uTransparentBg>.5?(mode==2?.85:line):1.0);}
