#include <flutter/runtime_effect.glsl>
precision highp float;

// Parameter plane for f_c(z)=(z-1)(z^2+z+c)=z^3+(c-1)z-c.
// Unlike a Newton basin, each pixel is the coefficient c while z starts from
// one shared seed; colors encode convergence time and attracting root phase.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uSeedRe; uniform float uSeedIm; uniform float uDamping;
out vec4 fragColor;
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
vec2 cdiv(vec2 a,vec2 b){float d=max(dot(b,b),1e-12);return vec2(a.x*b.x+a.y*b.y,a.y*b.x-a.x*b.y)/d;}
vec3 pal(float t,float s){float k=floor(s+0.5);return clamp(0.5+0.5*cos(6.283185*(vec3(t)+vec3(.09*k,.34+.02*k,.68+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){
 vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));
 vec2 c=(fc-.5*uResolution)/size*4.0/max(uZoom,.001)+uCenter;
 vec2 z=vec2(uSeedRe,uSeedIm);int cap=int(clamp(uIterations,12.0,160.0));float done=float(cap);float residual=1.0;
 for(int i=0;i<160;i++){if(i>=cap)break;vec2 z2=cmul(z,z),z3=cmul(z2,z);vec2 f=z3+cmul(c-vec2(1.0,0.0),z)-c;vec2 df=3.0*z2+c-vec2(1.0,0.0);residual=length(f);if(residual<1e-5){done=float(i);break;}z-=clamp(uDamping,.2,1.2)*cdiv(f,df);if(dot(z,z)>uBailout*uBailout*64.0){done=float(i);break;}}
 float phase=fract(atan(z.y,z.x)/6.283185+1.0);float t=fract(phase+.65*done/float(cap));vec3 col=pal(t,uColorScheme)*(1.0-.55*done/float(cap));col+=.18*exp(-40.0*residual);
 fragColor=vec4(srgb(col),uTransparentBg>.5?clamp(1.0-done/float(cap)*.45,.3,1.0):1.0);
}
