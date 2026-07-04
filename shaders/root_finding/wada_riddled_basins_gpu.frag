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
uniform float uBasinCount;
uniform float uRiddleScale;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin){lin=clamp(lin,0.0,1.0);bvec3 cut=lessThan(lin,vec3(0.0031308));vec3 hi=1.055*pow(max(lin,vec3(0.0031308)),vec3(1.0/2.4))-0.055;return mix(hi,lin*12.92,vec3(cut));}
vec3 palette(float t,float s){vec3 a=vec3(0.5),b=vec3(0.5),c=vec3(1),d=vec3(0,0.33,0.67);if(mod(s,8.0)<4.0){a=vec3(0.08,0.10,0.22);b=vec3(0.35,0.25,0.52);d=vec3(0.55,0.22,0.08);}return a+b*cos(6.28318*(c*t+d));}

float basin(vec2 p, int n){
  vec2 v=p; float best=1e9; float cls=0.0;
  for(int i=0;i<5;i++){ if(i>=n)break; float a=6.2831853*float(i)/float(n); vec2 c=vec2(cos(a),sin(a))*0.75; float d=length(v-c); if(d<best){best=d; cls=float(i);} }
  // ponytail: basin perturbation is sampled per neighbour; 12 rounds keeps riddling without 9*32 loops.
  for(int k=0;k<12;k++){ vec2 q=vec2(sin(v.y*2.1)+0.55*sin(v.x*3.0), cos(v.x*1.7)-0.45*sin(v.y*2.6)); v=mix(v,q,0.42); }
  float riddled=sin((v.x*37.0+v.y*41.0)*uRiddleScale)+sin((v.x-v.y)*71.0*uRiddleScale);
  return mod(cls + step(1.2,riddled), float(n));
}

void main(){
  vec2 fragCoord=FlutterFragCoord().xy; float scalePix=max(1.0,min(uResolution.x,uResolution.y));
  vec2 uv=(fragCoord-0.5*uResolution)/scalePix; vec2 p=uv*3.0/max(uZoom,0.0001)+uCenter;
  int n=int(clamp(floor(uBasinCount+0.5),3.0,5.0));
  float c0=basin(p,n);
  float ridge=abs(sin((p.x*37.0+p.y*41.0)*uRiddleScale))*abs(sin((p.x-p.y)*71.0*uRiddleScale));
  float radial=abs(sin((atan(p.y,p.x)*float(n)+length(p)*9.0)));
  float wada=smoothstep(0.42,0.88,max(ridge,radial));
  float riddled=0.5+0.5*sin((p.x*83.0+p.y*47.0)*clamp(uRiddleScale,0.2,2.0));
  vec3 base=palette(fract(c0/float(n)+0.1*riddled),uColorScheme)*0.45;
  vec3 heat=mix(vec3(0.05,0.08,0.16),vec3(1.0,0.25,0.08),wada);
  vec3 color=mix(base,heat,wada); color+=vec3(0.8,0.9,1.0)*pow(riddled*wada,4.0)*0.22;
  float alpha=uTransparentBg>0.5?max(wada,0.2):1.0; fragColor=vec4(linearToSRGB(color),alpha);
}
