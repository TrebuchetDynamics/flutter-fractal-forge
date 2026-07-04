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
uniform float uGeneratorCount;
uniform float uBend;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin){lin=clamp(lin,0.0,1.0);bvec3 cut=lessThan(lin,vec3(0.0031308));vec3 hi=1.055*pow(max(lin,vec3(0.0031308)),vec3(1.0/2.4))-0.055;return mix(hi,lin*12.92,vec3(cut));}
vec2 cdiv(vec2 a,vec2 b){return vec2(a.x*b.x+a.y*b.y,a.y*b.x-a.x*b.y)/max(dot(b,b),1e-6);} 
vec3 palette(float t,float s){vec3 a=vec3(0.5),b=vec3(0.5),c=vec3(1),d=vec3(0,0.33,0.67);if(mod(s,8.0)<5.0){a=vec3(0.06,0.13,0.25);b=vec3(0.22,0.36,0.50);d=vec3(0.16,0.34,0.62);}return a+b*cos(6.28318*(c*t+d));}

void main(){
  vec2 fragCoord=FlutterFragCoord().xy; float scalePix=max(1.0,min(uResolution.x,uResolution.y));
  vec2 uv=(fragCoord-0.5*uResolution)/scalePix; vec2 z=uv*2.4/max(uZoom,0.0001)+uCenter;
  float r=length(z); if(r>1.35){float a=uTransparentBg>0.5?0.0:1.0; fragColor=vec4(0.0,0.0,0.0,a); return;}
  int gens=int(clamp(floor(uGeneratorCount+0.5),3.0,8.0)); int maxIter=int(clamp(uIterations,8.0,128.0));
  float bend=clamp(uBend,0.0,1.6); float hits=0.0; float code=0.0; float edge=10.0;
  for(int k=0;k<128;k++){ if(k>=maxIter)break; bool moved=false; for(int i=0;i<8;i++){ if(i>=gens)break; float a=6.2831853*float(i)/float(gens); vec2 c=vec2(cos(a),sin(a))*(0.82+0.12*sin(bend)); float rad=0.58+0.18*cos(bend+a); vec2 d=z-c; float l=length(d); edge=min(edge,abs(l-rad)); if(l<rad){z=c+d*(rad*rad/max(dot(d,d),1e-6)); z=cdiv(z+vec2(0.08*bend,0.04*bend),vec2(1,0)+vec2(0.05*bend,-0.07*bend)*z); hits+=1.0; code+=float(i+1)*0.13; moved=true;}}
    if(!moved)break;
  }
  float lace=exp(-edge*85.0/max(uZoom,0.25)); float limit=smoothstep(0.02,0.85,hits/max(uIterations,1.0));
  float disk=1.0-smoothstep(0.98,1.25,r); vec3 color=palette(fract(code*0.05+hits*0.021),uColorScheme)*(0.25+0.85*max(lace,limit))*disk;
  color+=vec3(0.9,0.84,1.0)*lace*0.38; float alpha=max(lace,limit)*disk; if(uTransparentBg<=0.5){color=mix(vec3(0.006,0.007,0.014),color,alpha);alpha=1.0;} fragColor=vec4(linearToSRGB(color),alpha);
}
