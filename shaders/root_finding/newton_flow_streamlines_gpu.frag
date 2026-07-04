#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uDegree;
uniform float uFlowStrength;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) { lin = clamp(lin,0.0,1.0); bvec3 cut=lessThan(lin,vec3(0.0031308)); vec3 hi=1.055*pow(max(lin,vec3(0.0031308)),vec3(1.0/2.4))-0.055; return mix(hi,lin*12.92,vec3(cut)); }
vec2 cmul(vec2 a, vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);} 
vec2 cdiv(vec2 a, vec2 b){return vec2(a.x*b.x+a.y*b.y,a.y*b.x-a.x*b.y)/max(dot(b,b),1e-8);} 
vec2 cpowN(vec2 z,int n){vec2 r=vec2(1.0,0.0); for(int i=0;i<6;i++){if(i>=n)break; r=cmul(r,z);} return r;}
vec3 palette(float t,float s){
  int scheme=int(clamp(floor(s+0.5),0.0,63.0));
  if(scheme==0)return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  if(scheme==1)return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  if(scheme==2)return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  if(scheme==3){float g=0.5+0.5*cos(6.28318*t);return vec3(g);}
  float sf=float(scheme);
  vec3 a=0.55+0.15*sin(vec3(1.0,2.0,3.0)*(0.37*sf+0.1));
  vec3 b=0.45+0.25*cos(vec3(1.7,2.3,2.9)*(0.29*sf+0.2));
  vec3 c=1.0+0.80*sin(vec3(0.8,1.3,1.7)*(0.11*sf+0.3));
  vec3 d=fract(sin(vec3(12.9898,78.233,37.719)*(sf+0.5))*43758.5453);
  return clamp(a+b*cos(6.28318*(c*t+d)),0.0,1.0);
}

void main(){
  vec2 fragCoord=FlutterFragCoord().xy; float scalePix=max(1.0,min(uResolution.x,uResolution.y));
  vec2 uv=(fragCoord-0.5*uResolution)/scalePix; vec2 z=uv*3.0/max(uZoom,0.0001)+uCenter;
  int degree=int(clamp(floor(uDegree+0.5),3.0,6.0)); int maxIter=int(clamp(uIterations,20.0,160.0));
  vec2 flow=vec2(0.0); vec2 zn=z; float speed=0.0; float cls=0.0;
  for(int i=0;i<160;i++){ if(i>=maxIter)break; vec2 f=cpowN(zn,degree)-vec2(1,0); vec2 df=float(degree)*cpowN(zn,degree-1); vec2 v=-cdiv(f,df); speed+=length(v); flow+=normalize(v+1e-5)*0.02; zn += v*0.08*clamp(uFlowStrength,0.1,2.0); if(length(f)<0.0002)break; }
  cls=floor(mod((atan(zn.y,zn.x)+3.14159265)/6.2831853*float(degree)+0.5,float(degree)));
  float stream=0.5+0.5*sin(dot(z+flow,vec2(18.0,27.0))+speed*2.4+uTime*0.0004);
  stream=smoothstep(0.72,0.96,stream);
  float basin=cls/max(float(degree-1),1.0);
  float tone=fract(basin+speed*0.01);
  vec3 base=palette(tone,uColorScheme)*0.55;
  vec3 lineColor=palette(fract(tone+0.37+speed*0.005),uColorScheme);
  vec3 color=base+lineColor*stream*(0.35+0.35*smoothstep(0.0,8.0,speed));
  float alpha=uTransparentBg>0.5?max(stream,0.25):1.0; fragColor=vec4(linearToSRGB(color),alpha);
}
