#include <flutter/runtime_effect.glsl>
precision highp float;
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter; uniform float uZoom; uniform float uIterations; uniform float uBailout; uniform float uColorScheme; uniform float uTransparentBg; uniform float uR;
out vec4 fragColor;
vec3 linearToSRGB(vec3 x){x=clamp(x,0.0,1.0);bvec3 c=lessThan(x,vec3(0.0031308));return mix(1.055*pow(max(x,vec3(0.0031308)),vec3(1.0/2.4))-0.055,x*12.92,vec3(c));}
void main(){vec2 fc=FlutterFragCoord().xy;float sc=min(uResolution.x,uResolution.y);vec2 p=(fc-.5*uResolution)/max(1.0,sc)/max(uZoom,1e-6)+uCenter;mat2 X=mat2(.45+p.x,.2*p.y,-.2*p.y,.55-p.x);mat2 I=mat2(1,0,0,1);int steps=int(clamp(uIterations,1.0,160.0));float tr=0.0,det=0.0;for(int i=0;i<160;i++){if(i>=steps)break;X=uR*X*(I-X);tr=X[0][0]+X[1][1];det=X[0][0]*X[1][1]-X[0][1]*X[1][0];if(abs(tr)+abs(det)>uBailout)break;}float disc=max(0.0,tr*tr-4.0*det);float e=.5*(tr+sqrt(disc));vec3 col=.5+.5*cos(6.28318*(e*.1+vec3(0,.33,.67)));fragColor=vec4(linearToSRGB(col),1.0);}
