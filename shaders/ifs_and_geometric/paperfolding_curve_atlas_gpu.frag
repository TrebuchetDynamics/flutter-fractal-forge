#include <flutter/runtime_effect.glsl>
precision highp float;

// Regular paperfolding curve generated from its turn sequence. For turn n,
// remove factors of two; residues 1 and 3 mod 4 select left and right folds.
uniform float uTime; uniform vec2 uResolution; uniform vec2 uCenter;
uniform float uZoom; uniform float uIterations; uniform float uBailout;
uniform float uColorScheme; uniform float uTransparentBg;
uniform float uVariant; uniform float uLineWeight;
out vec4 fragColor;
int imod(int a,int b){return a-(a/b)*b;}
float segDist(vec2 p,vec2 a,vec2 b){vec2 v=b-a;float h=clamp(dot(p-a,v)/max(dot(v,v),1e-9),0.0,1.0);return length(p-a-h*v);}
vec3 pal(float t,float s){float k=floor(s+.5);return clamp(.5+.5*cos(6.283185*(vec3(t)+vec3(.1*k,.34+.02*k,.67+.04*k))),0.0,1.0);}
vec3 srgb(vec3 c){c=clamp(c,0.0,1.0);return mix(12.92*c,1.055*pow(c,vec3(1.0/2.4))-.055,step(vec3(.0031308),c));}
void main(){vec2 fc=FlutterFragCoord().xy;float size=max(1.0,min(uResolution.x,uResolution.y));vec2 p=(fc-.5*uResolution)/size/max(uZoom,.001)+uCenter;int depth=int(clamp(floor(uIterations/8.0),4.0,9.0)),segments=1;for(int d=0;d<9;d++){if(d>=depth)break;segments*=2;}float stepLen=1.45/sqrt(float(segments));vec2 pos=vec2(-.42,-.18),dir=vec2(1,0);float dist=10.0,along=0.0;int variant=int(clamp(floor(uVariant+.5),0.0,2.0));for(int i=0;i<512;i++){if(i>=segments)break;vec2 next=pos+dir*stepLen;float sd=segDist(p,pos,next);if(sd<dist){dist=sd;along=float(i)/float(segments);}pos=next;if(i+1<segments){int n=i+1,m=n;for(int k=0;k<9;k++){if(imod(m,2)!=0)break;m/=2;}int r=imod(m,4);float turn=r==1?1.0:-1.0;if(variant==1)turn=-turn;if(variant==2&&imod(i,3)==0)turn=-turn;dir=turn>0.0?vec2(-dir.y,dir.x):vec2(dir.y,-dir.x);}}float line=1.0-smoothstep(uLineWeight,uLineWeight*2.2,dist);vec3 bg=pal(fract(length(p)*.12),uColorScheme)*.035;vec3 col=mix(bg,pal(along,uColorScheme),line);fragColor=vec4(srgb(col),uTransparentBg>.5?line:1.0);}
