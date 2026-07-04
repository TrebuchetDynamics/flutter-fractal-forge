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
uniform float uKnotTurns;
uniform float uPearlRadius;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin){lin=clamp(lin,0.0,1.0);bvec3 cut=lessThan(lin,vec3(0.0031308));vec3 hi=1.055*pow(max(lin,vec3(0.0031308)),vec3(1.0/2.4))-0.055;return mix(hi,lin*12.92,vec3(cut));}
vec3 palette(float t,float s){vec3 a=vec3(0.5),b=vec3(0.5),c=vec3(1),d=vec3(0,0.33,0.67);if(mod(s,8.0)<4.0){a=vec3(0.30,0.14,0.06);b=vec3(0.50,0.28,0.12);c=vec3(1,0.75,0.4);d=vec3(0,0.13,0.28);}return a+b*cos(6.28318*(c*t+d));}

vec2 knot(float t,float turns){
  float p=turns; float q=turns+2.0; float r=0.72+0.22*cos(q*t);
  return vec2(r*cos(p*t), r*sin(p*t))*0.9 + vec2(0.10*cos(q*t),0.18*sin(q*t));
}

void main(){
  vec2 fragCoord=FlutterFragCoord().xy; float scalePix=max(1.0,min(uResolution.x,uResolution.y));
  vec2 uv=(fragCoord-0.5*uResolution)/scalePix; vec2 p=uv*2.8/max(uZoom,0.0001)+uCenter;
  int pearls=int(clamp(uIterations,24.0,144.0)); float turns=floor(clamp(uKnotTurns,2.0,7.0)+0.5); float rad=clamp(uPearlRadius,0.04,0.22);
  float d=10.0; float glow=0.0; float idx=0.0;
  vec2 prev=knot(0.0,turns);
  for(int i=1;i<144;i++){ if(i>=pearls)break; float t=6.2831853*float(i)/float(pearls-1); vec2 c=knot(t+0.05*sin(uTime*0.00012),turns); float pd=abs(length(p-c)-rad*(0.65+0.35*sin(t*turns))); if(pd<d){d=pd;idx=float(i)/float(pearls);} vec2 pa=p-prev; vec2 ba=c-prev; float h=clamp(dot(pa,ba)/max(dot(ba,ba),0.0001),0.0,1.0); float sd=length(pa-ba*h); glow+=exp(-sd*32.0)*0.012; prev=c; }
  float pearl=1.0-smoothstep(0.006,0.035,d); float halo=exp(-d*28.0)+glow;
  vec3 color=palette(fract(idx+halo*0.2),uColorScheme)*(0.35+0.75*max(pearl,halo*0.35)); color+=vec3(0.85,0.9,1.0)*pearl*0.22;
  float alpha=max(pearl,halo*0.35); if(uTransparentBg<=0.5){color=mix(vec3(0.006,0.006,0.013),color,clamp(alpha,0.0,1.0));alpha=1.0;} fragColor=vec4(linearToSRGB(color),alpha);
}
