Shader "Basic/BasicWaterFlat"
{
	Properties
	{	
		[Space]_Color("水面颜色", Color) = (1,1,1,1)
		
		_MainLightColor("手动填写主光源颜色", Color) = (1,1,1,1)
		_AmbientColor("手动填写主环境光颜色", Color) = (0,0,0,0)
		
		_ColorContrast ("颜色对比度", Range(0.1, 5)) = 1.4
		
		_EdgeColor("岸边颜色", Color) = (1,1,1,1)
		_PondColor("深处颜色", Color) = (1,1,1,1)
		
		_SurfaceTex ("水面贴图", 2D) = "white" {}
		
        _SurfaceMoveX ("流动速度X", Range(-1, 1)) = 0
		_SurfaceMoveY ("流动速度Y ", Range(-1, 1)) = 0
		
		_SurfaceWaveSpeedX ("时域水面波动频率 x ", Range(0, 150)) = 1
		_SurfaceWaveSpeedY ("时域水面波动频率 y ", Range(0, 150)) = 1
		_SurfaceWaveSpeedX2 ("空间域水面波动频率 x ", Range(0, 150)) = 1
		_SurfaceWaveSpeedY2 ("空间域水面波动频率 y ", Range(0, 150)) = 1
		_SurfaceWaveAmplitude ("水面波动振幅", Range(0, 0.1)) = 0.03		
		
		
		[Space]_BottomColor("水底颜色", Color) = (1,1,1,1)
		_BottomTex ("水底贴图", 2D) = "white" {}
		
        _BottomWaveMoveX ("水底流动速度X 跟水面流动速度X相乘", Range(-1, 1)) = 1
		_BottomWaveMoveY ("水底流动速度Y 跟水面流动速度Y相乘 ", Range(-1, 1)) = 0
		
        _BottomWaveSpeedX ("时域水底波动频率 x ", Range(0, 150)) = 1
		_BottomWaveSpeedY ("时域水底波动频率 y ", Range(0, 150)) = 1
        _BottomWaveSpeedX2 ("空间域水底波动频率 x ", Range(0, 150)) = 1
		_BottomWaveSpeedY2 ("空间域水底波动频率 y ", Range(0, 150)) = 1
		_BottomWaveAmplitude ("水底波动振幅", Range(0, 0.1)) = 0.03		
    }
    
	CGINCLUDE
	
	sampler2D _SurfaceTex;
	sampler2D _BottomTex;
	
	float4 _SurfaceTex_ST;
	float4 _BottomTex_ST;
	float4 _Color;
	float4 _EdgeColor;
	float4 _PondColor;
	float4 _BottomColor;
	float4 _MainLightColor;
	float4 _AmbientColor;
	float _ColorContrast;
	float _SurfaceMoveX;
	float _SurfaceMoveY;
	float _SurfaceWaveSpeedX;
	float _SurfaceWaveSpeedY;
	float _SurfaceWaveSpeedX2;
	float _SurfaceWaveSpeedY2;
	float _SurfaceWaveAmplitude;
	float _BottomWaveMoveX;
	float _BottomWaveMoveY;
	float _BottomWaveSpeedX;
	float _BottomWaveSpeedY;
    float _BottomWaveSpeedX2;
	float _BottomWaveSpeedY2;
	float _BottomWaveAmplitude;	
    UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);

	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 200

		Pass
		{
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            //ZWrite Off ZTest Always
            
			//cull off
			CGPROGRAM
			
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
			
			#pragma vertex pbrVert
			#pragma fragment pbrFrag
			#pragma multi_compile_instancing
			
            struct appdata_t
            {
                float4 color : COLOR;
                float4 vertex :POSITION;
                float3 normal :NORMAL;
                float4 uv :TEXCOORD0;
                float4 tangent : TANGENT;
            };

              
            struct v2f
            {
                float4 vertex :SV_POSITION;
                float4 color :COLOR;
                float3 normal :NORMAL;
                float2 uv : TEXCOORD0;
            	float3 tangentDir : TEXCOORD1;
		        float3 bitangentDir : TEXCOORD2;
		        float4 verPos : TEXCOORD3;
		        unityShadowCoord4 _ShadowCoord : TEXCOORD4;
            };
              

            v2f pbrVert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);        
                o.uv = v.uv;
                o.normal = v.normal;
                o.color = v.color;
                                
                o.verPos.xyz =  mul(unity_ObjectToWorld, v.vertex).xyz;
                o.verPos.w = o.vertex.z;
                
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normal, o.tangentDir) * v.tangent.w);
                o._ShadowCoord = mul (unity_WorldToShadow[0], mul(unity_ObjectToWorld,v.vertex));
                return o;
            }
        
            float4 pbrFrag (v2f i) : SV_Target
            { 
                float4 finalColor = _Color;
                
                float2 uv_water = i.uv;
                
                float xx0 = sin( _Time.y * _SurfaceWaveSpeedX + uv_water.x * _SurfaceWaveSpeedX2 ) * _SurfaceWaveAmplitude;
                float yy0 = sin( _Time.y * _SurfaceWaveSpeedY + uv_water.y * _SurfaceWaveSpeedY2 ) * _SurfaceWaveAmplitude;
                
                uv_water.x += (_Time.y *_SurfaceMoveX + xx0);
                uv_water.y += (_Time.y *_SurfaceMoveY + yy0);
                
                float4 mainColor = tex2D(_SurfaceTex, TRANSFORM_TEX(uv_water , _SurfaceTex));
                
                mainColor.rgb *= _Color.rgb;
                
                
                float2 uv_water_bottom = i.uv;
                
                uv_water_bottom.x += (_Time.y *_SurfaceMoveX * _BottomWaveMoveX + xx0);
                uv_water_bottom.y += (_Time.y *_SurfaceMoveY * _BottomWaveMoveY + yy0);
                
                float xx = sin( _Time.y * _BottomWaveSpeedX + i.uv.x * _BottomWaveSpeedX2 )*_BottomWaveAmplitude;
                float yy = sin( _Time.y * _BottomWaveSpeedY + i.uv.y * _BottomWaveSpeedY2 )*_BottomWaveAmplitude;
                
                uv_water_bottom.x += xx;
                uv_water_bottom.y += yy;
                
                float4 bottomColor = tex2D(_BottomTex, TRANSFORM_TEX(uv_water_bottom , _BottomTex));
                bottomColor.rgb *= _BottomColor.rgb;
                
                _EdgeColor.rgb *= bottomColor.rgb;
                _PondColor.rgb *= bottomColor.rgb;
                
                float m = pow(i.color.r, 1.0);
                float4 depthColor = lerp(_EdgeColor, _PondColor ,m);
                
                finalColor.rgb = lerp(depthColor.rgb, mainColor.rgb, _Color.a*mainColor.a);
                
                //finalColor.rgb = finalColor.rgb * _LightColor0.xyz + UNITY_LIGHTMODEL_AMBIENT.xyz;
                finalColor.rgb = finalColor.rgb * _MainLightColor.xyz + _AmbientColor.xyz;
                
                finalColor.rgb = pow(finalColor,_ColorContrast);                
                
                i._ShadowCoord.x -= xx0*0.1;
                i._ShadowCoord.y -= yy0*0.1;
                
                float shadowColor = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, i._ShadowCoord.xyz);
                shadowColor = lerp(0.75, 1, shadowColor);
                finalColor.rgb *= shadowColor;
                finalColor.a = _BottomColor.a;
                
                return finalColor;
            }

			ENDCG
		}
	}
}
