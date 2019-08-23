// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVJOB Water Shader - simple and fast. MIT license - license_nvjob.txt
// NVJOB Water Shader - simple and fast V1.4.2 - https://github.com/nvjob/nvjob-water-shader-simple-and-fast
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


Shader "Custom/Water Shader (simple and fast)2" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties{
//----------------------------------------------

_Color("Main Color", Color) = (0.15,0.161,0.16,1)
_SpecColor("Specular Color", Color) = (0.086,0.086,0.086,1)
_ReflectColor("Reflection Color", Color) = (0.28,0.29,0.25,0.5)

_MainTex("Main Texture", 2D) = "white" {}
_Detail("Main Detail", 2D) = "gray" {}
_BumpMap("Normalmap", 2D) = "bump" {}
_BumpMapDetail("Normalmap Detail", 2D) = "bump" {}
_ParallaxMap("Heightmap", 2D) = "black" {}
_Cube("Reflection Cubemap", Cube) = "" {}

_Shininess("Shininess", Range(0.01, 1)) = 0.15

_IntensityMt("Intensity Main Texture", Range(0.1, 5)) = 1
_ContrastMt("Contrast Main Texture", Range(-0.5, 3)) = 1
_MainDetailScale("Main Detail Uv", Range(0.001, 10)) = 1
_MainDetailFlow("Main Detail Flow", Range(0, 2)) = 1

_IntensityNm("Intensity Normalmap", Range(0.001, 10)) = 1
_NormalmapDetailScale("Normalmap Detail Uv", Range(0.001, 10)) = 0.5
_NormalmapDetailSpeed("Normalmap Detail Speed", Range(-1, 1)) = 0.5

_MicrowaveScale("Microwave Uv", Range(0.5, 10)) = 1
_IntensityMicrowave("Intensity Microwave", Range(0.001, 1.5)) = 0.5

_IntensityRef("Intensity Reflection", Range(0, 10)) = 0.15

_ParallaxScale("Heightmap Uv", Range(0.001, 20)) = 1
_Parallax("Heightmap", Range(-0.2, 0.2)) = 0.1
_ReverseFlow("Reverse Flow", Range(-5, 5)) = 1

_SoftFactor("Soft Factor", Range(0.0001, 1)) = 0.5

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags{ "Queue" = "Geometry+800" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
LOD 200
Cull Off
ZWrite On
ColorMask 0

CGPROGRAM
#pragma surface surf BlinnPhong alpha:fade vertex:vert exclude_path:prepass nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights //halfasview
#pragma target 3.0

//----------------------------------------------

sampler2D _MainTex, _Detail, _BumpMap, _BumpMapDetail, _ParallaxMap;
samplerCUBE _Cube;
fixed4 _Color, _ReflectColor;
half _Shininess, _IntensityMt, _ContrastMt, _IntensityNm, _NormalmapDetailScale, _NormalmapDetailSpeed, _MicrowaveScale, _IntensityMicrowave, _IntensityRef, _MainDetailScale, _Parallax, _ParallaxScale, _SoftFactor;
half _WaterLocalUvX, _WaterLocalUvZ, _WaterLocalUvNX, _WaterLocalUvNZ;
half _MainDetailFlow, _ReverseFlow;
sampler2D_float _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;

//----------------------------------------------

struct Input {
float2 uv_MainTex;
float2 uv_BumpMap;
float3 worldRefl;
float4 screenPos;
float eyeDepth;
float3 viewDir;
INTERNAL_DATA
};

//----------------------------------------------

void vert(inout appdata_full v, out Input o) {
UNITY_INITIALIZE_OUTPUT(Input, o);
COMPUTE_EYEDEPTH(o.eyeDepth);
}

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {

half2 uvnh = IN.uv_BumpMap;
uvnh.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * -_ReverseFlow;

half h = tex2D(_ParallaxMap, uvnh * _ParallaxScale).r;
half2 offset = ParallaxOffset(h, _Parallax, IN.viewDir);
IN.uv_MainTex -= offset;
IN.uv_BumpMap += offset;

half2 uv = IN.uv_MainTex;
uv.xy += half2(_WaterLocalUvX, _WaterLocalUvZ);

half2 uvd = IN.uv_MainTex;
uvd.xy += half2(_WaterLocalUvX, _WaterLocalUvZ) * _MainDetailFlow;

half2 uvn = IN.uv_BumpMap;
uvn.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ);

half2 uvnd = IN.uv_BumpMap;
uvnd.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalmapDetailSpeed;

fixed4 tex = tex2D(_MainTex, uv) * _Color;
tex *= tex2D(_Detail, uvd * _MainDetailScale);
tex *= _IntensityMt;
o.Albedo = ((tex - 0.5) * _ContrastMt + 0.5).rgb;

o.Gloss = tex.a;
o.Specular = _Shininess;

fixed3 normal = UnpackNormal(tex2D(_BumpMap, uvn));
normal += UnpackNormal(tex2D(_BumpMapDetail, uvnd * _NormalmapDetailScale));
normal += UnpackNormal(tex2D(_BumpMapDetail, uvnh * 5 * _MicrowaveScale)) * _IntensityMicrowave;
normal *= _IntensityNm;
o.Normal = normal;

fixed4 reflcol = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
reflcol *= _IntensityRef;
reflcol *= tex.a;
o.Emission = reflcol.rgb * _ReflectColor.rgb;

half rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + 0.0001));
half fade = saturate(_SoftFactor * (LinearEyeDepth(rawZ) - IN.eyeDepth));
o.Alpha = _Color.a * fade;

}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

		Pass
        {
 
         CGPROGRAM
 
 
         #pragma vertex vert
         #pragma fragment frag
           
         #include "UnityCG.cginc"
 
         struct appdata
         {
           float4 vertex : POSITION;
           float2 uv : TEXCOORD0;
           float3 normal : NORMAL; 
         };
 
         struct v2f
         {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float3 viewDir : COLOR;
            float3 normal : COLOR2;    
            float fillEdge : TEXCOORD2;
         };
 
         sampler2D _MainTex;		 
         float4 _MainTex_ST;
         float _FillAmount, _WobbleX, _WobbleZ;
         float4 _TopColor, _RimColor, _FoamColor, _Tint;
         float _Rim, _RimPower;
           
         float4 RotateAroundYInDegrees (float4 vertex, float degrees)
         {
            float alpha = degrees * UNITY_PI / 180;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, sina, -sina, cosa);
            return float4(vertex.yz , mul(m, vertex.xz)).xzyw ;            
         }
     
 
         v2f vert (appdata v)
         {
            v2f o;
 
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);    
            // get world position of the vertex
            float3 worldPos = mul (unity_ObjectToWorld, v.vertex.xyz);  
            // rotate it around XY
            float3 worldPosX= RotateAroundYInDegrees(float4(worldPos,0),360);
            // rotate around XZ
            float3 worldPosZ = float3 (worldPosX.y, worldPosX.z, worldPosX.x);     
            // combine rotations with worldPos, based on sine wave from script
            float3 worldPosAdjusted = worldPos + (worldPosX  * _WobbleX)+ (worldPosZ* _WobbleZ);
            // how high up the liquid is
            o.fillEdge =  worldPosAdjusted.y + _FillAmount;
 
            o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
            o.normal = v.normal;
            return o;
         }
           
         fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
         {
           // sample the texture
           fixed4 col = tex2D(_MainTex, i.uv) * _Tint;		   
           
           // rim light
           float dotProduct = 1 - pow(dot(i.normal, i.viewDir), _RimPower);
           float4 RimResult = smoothstep(0.5, 1.0, dotProduct);
           RimResult *= _RimColor;
 
           // foam edge
           float4 foam = ( step(i.fillEdge, 0.5) - step(i.fillEdge, (0.5 - _Rim)))  ;
           float4 foamColored = foam * (_FoamColor * 0.9);
           // rest of the liquid
           float4 result = step(i.fillEdge, 0.5) - foam;		   
           float4 resultColored = result * col;		   
           // both together, with the texture
           float4 finalResult = resultColored + foamColored;               
           finalResult.rgb += RimResult;				   
 
           // color of backfaces/ top
           float4 topColor = _TopColor * (foam + result);		   
           //VFACE returns positive for front facing, negative for backfacing
           //return facing > 0 ? finalResult: topColor;	
		   
		   return finalResult;
               
         }
         ENDCG
		 }
        }


FallBack "Legacy Shaders/Reflective/Bumped Diffuse"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
