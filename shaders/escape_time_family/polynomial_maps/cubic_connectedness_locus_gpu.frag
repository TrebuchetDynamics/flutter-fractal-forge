#include <flutter/runtime_effect.glsl>
precision highp float;

// Branner-Hubbard cubic slice: f(z)=z^3-3a^2 z+b.  A cubic is connected
// exactly when both critical orbits (starting at +a and -a) remain bounded.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uAReal;
uniform float uAImag;
uniform float uMode;
out vec4 fragColor;

vec2 cmul(vec2 a, vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec3 pal(float t,float s){float k=floor(s+0.5);return clamp(0.5+0.5*cos(6.283185*(vec3(t)+vec3(0.07*k,0.33+0.03*k,0.67+0.05*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-0.055,step(vec3(0.0031308),c));}

void main(){
  vec2 fc=FlutterFragCoord().xy;
  float size=max(1.0,min(uResolution.x,uResolution.y));
  vec2 b=(fc-0.5*uResolution)/size*3.2/max(uZoom,0.001)+uCenter;
  vec2 a=vec2(uAReal,uAImag), a2=cmul(a,a);
  vec2 z0=a, z1=-a;
  int cap=int(clamp(uIterations,20.0,240.0));
  float limit=max(4.0,uBailout*uBailout), e0=float(cap),e1=float(cap);
  float trap0=10.0,trap1=10.0;
  for(int i=0;i<240;i++){
    if(i>=cap)break;
    if(e0>=float(cap)){vec2 z2=cmul(z0,z0);z0=cmul(z2,z0)-3.0*cmul(a2,z0)+b;trap0=min(trap0,length(z0));if(dot(z0,z0)>limit)e0=float(i+1);}
    if(e1>=float(cap)){vec2 z2=cmul(z1,z1);z1=cmul(z2,z1)-3.0*cmul(a2,z1)+b;trap1=min(trap1,length(z1));if(dot(z1,z1)>limit)e1=float(i+1);}
  }
  int mode=int(clamp(floor(uMode+0.5),0.0,2.0));
  float bounded=step(float(cap)-0.5,min(e0,e1));
  float t=mode==0?fract((e0+e1)/(2.0*float(cap))+0.12*abs(e0-e1)):mode==1?fract(abs(e0-e1)/float(cap)+0.1*atan(z0.y,z0.x)):fract(0.7/(0.05+min(trap0,trap1)));
  vec3 col=mix(pal(t,uColorScheme),vec3(0.015,0.02,0.035),bounded);
  if(bounded>0.5)col+=0.12*pal(fract(atan(b.y,b.x)/6.283185),uColorScheme);
  fragColor=vec4(srgb(col),uTransparentBg>0.5?max(0.25,1.0-bounded*0.45):1.0);
}
