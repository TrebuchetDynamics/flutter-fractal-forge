#include <flutter/runtime_effect.glsl>
precision highp float;
// Complex Hénon Julia slice: H_{a,c}(z,w)=(z^2+c-a*w, z).
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uA; uniform vec2 uC;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
vec3 pal(float t){return 0.5+0.5*cos(6.28318*(t+vec3(0.0,0.33,0.67)));}
vec2 cmul(vec2 a, vec2 b){return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 uv=(fc-.5*uResolution)/max(1.0,sc);vec2 z=uv/max(uZoom,1e-6)+uCenter;vec2 w=vec2(0.0);float b2=max(4.0,uBailout*uBailout);int target=int(clamp(uIterations,1.0,500.0));int it=target;for(int i=0;i<500;i++){if(i>=target)break;vec2 nz=cmul(z,z)+uC-uA*w;w=z;z=nz;if(dot(z,z)+dot(w,w)>b2){it=i;break;}}float t= it>=target?0.65:float(it)/float(target)+0.08*log(1.0+dot(z,z));vec3 color=pal(fract(t+uTime*0.0001));if(it>=target)color*=0.35;if(length(color)<0.02&&uTransparentBg>0.5){fragColor=vec4(0);return;}fragColor=vec4(linearToSRGB(color),1.0);}
