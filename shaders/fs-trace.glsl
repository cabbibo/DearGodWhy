
uniform float time;

uniform samplerCube t_cube;
uniform sampler2D t_logo;
uniform vec3 mousePos;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_color;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

uniform float noiseSize1;
uniform float noiseSize2;


varying vec3 vPos;
varying vec3 vCam;
varying vec3 vNorm;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;
varying float vNoise;

varying vec3 vAudio;
varying vec3 vMousePos;


// Branch Code stolen from : https://www.shadertoy.com/view/ltlSRl
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float MAX_TRACE_DISTANCE = 1.0;             // max trace distance
const float INTERSECTION_PRECISION = 0.0001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 50;
const float PI = 3.14159;

const int NUM_COL_RAYS = 3;



$smoothU
$opU
$pNoise



vec3 vHash( vec3 x )
{
  x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
        dot(x,vec3(269.5,183.3,246.1)),
        dot(x,vec3(113.5,271.9,124.6)));

  return fract(sin(x)*43758.5453123);
}



vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv(float h, float s, float v)
{
    
  return mix( vec3( 1.0 ), clamp( ( abs( fract(
    h + vec3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}


float fNoise( vec3 pos ){
    float n = pNoise( pos * 200. * noiseSize1 + .1 * vec3( time ));
    float n2 = pNoise( pos * 40. * noiseSize2 + .1 * vec3( time ));
    return n * .005 + n2 * .01;
}







// green fur
vec3 col1( vec3 ro , vec3 rd ){

  vec3 col = hsv( fNoise(ro* 20.)*100., 1.,1.);
  return col;

}



// pin head
vec3 col3( vec3 ro , vec3 rd ){

  vec3 col = hsv( 1. + time * .1 , .4 , 1. );;
  for( int i = 0; i<10; i++){
    vec3 p = ro + rd * .01 * float( i );

    float n = fNoise( (p * .1 / length( p - vMousePos))  + vec3( 0., 0., time * .01)) * 100.;

    if( n < 1. && n > .8 ){
      col = hsv( float( i ) / 10. + time * .1 ,.3+.6*float(i)/10. , 1. );// / ( 1. + .1*float(i));
      break;////vec3(1.);
    }

    //col += hsv( n * 1. , 1. , 1. ) * n /100. ;


  }



  return col;// normalize(col);

}



vec3 render( vec3 ro , vec3 rd , float whichTrace ){

  if( whichTrace == 0. ){
    return col3( ro , rd );
  }else if( whichTrace == 1. ){
    return col1( ro , rd );
  }
  

}



void main(){

  vec3 fNorm =  vNorm; //uvNormalMap( t_normal , vPos , vUv * 20. , vNorm , .4 * pain , .6 * pain * pain);

  vec3 ro = vPos;// + vec3( sin( time ) * .01 , 0. , .1);

  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );

  


  //col += fNorm * .5 + .5;


  vec4 logo = texture2D( t_logo , vUv );

  float d = length(logo.xyz - vec3( 1. ));
  if( length( logo.xyz  )  < .2  ){ discard; }else{

    float whichTrace = 0.;
    if( length( logo.xyz  )  < .9){ whichTrace =1.;}

  col = render( ro , rd , whichTrace );

  //col = mix( col , vec3( 1. ) , 1. - logo.a );

  }

  col = mix(vec3( 0.), col  , logo.a * 1. );

 // col = normalize( vMousePos ) * .5 + .5;


  //col = vec3( 1. , 0., 0.);




  gl_FragColor = vec4( col , 1. );

}
