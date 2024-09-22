// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/OceanWater"
{
	Properties
	{
		_WaveSpeed("WaveSpeed", Float) = 1
		_WaterColor("WaterColor", Color) = (0.001957997,0.1867146,0.4150943,0)
		_WaveTile("WaveTile", Float) = 1
		_WaveColor("WaveColor", Color) = (0,0.1882353,0.4156863,1)
		_WaveColor2("WaveColor2", Color) = (0,0.1882353,0.4156863,1)
		_Tesselation("Tesselation", Float) = 8
		_SmallWaveSpeed("SmallWaveSpeed", Range( 0 , 5)) = 1
		_Height("Height", Float) = 1
		_WaveSize("Wave Size", Range( 0 , 10)) = 1
		_EdgePower("EdgePower", Range( 0 , 1)) = 1
		_EdgeDistance("EdgeDistance", Float) = 1
		_FoamTexture("FoamTexture", 2D) = "white" {}
		_WaveDirectionX("WaveDirectionX", Range( 0 , 1)) = 1
		_WaveDirectionY("WaveDirectionY", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform float _Height;
		uniform float _WaveSpeed;
		uniform float _WaveDirectionX;
		uniform float _WaveDirectionY;
		uniform float _WaveTile;
		uniform float _WaveSize;
		uniform float _SmallWaveSpeed;
		uniform float4 _WaterColor;
		uniform float4 _WaveColor;
		uniform float4 _WaveColor2;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _EdgeDistance;
		uniform sampler2D _FoamTexture;
		uniform float _EdgePower;
		uniform float _Tesselation;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float2 voronoihash59( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi59( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash59( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		float3 PerturbNormal107_g7( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_2 = (_Tesselation).xxxx;
			return temp_cast_2;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float4 appendResult156 = (float4(_WaveDirectionX , _WaveDirectionY , 0.0 , 0.0));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float4 appendResult159 = (float4((0.02 + (_WaveDirectionX - 0.0) * (0.15 - 0.02) / (1.0 - 0.0)) , (0.02 + (_WaveDirectionY - 0.0) * (0.15 - 0.02) / (1.0 - 0.0)) , 0.0 , 0.0));
			float4 WaveTileUV23 = ( ( WorldSpaceTile11 * appendResult159 ) * _WaveTile );
			float2 panner2 = ( temp_output_7_0 * appendResult156.xy + WaveTileUV23.xy);
			float simplePerlin2D1 = snoise( panner2 );
			float3 WaveHeight32 = ( ( float3(0,1,0) * _Height ) * simplePerlin2D1 );
			v.vertex.xyz += WaveHeight32;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g7 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g7 = ase_worldNormal;
			float time59 = ( _Time.y * _SmallWaveSpeed );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float2 coords59 = WorldSpaceTile11.xy * _WaveSize;
			float2 id59 = 0;
			float2 uv59 = 0;
			float voroi59 = voronoi59( coords59, time59, id59, uv59, 0 );
			float temp_output_62_0 = pow( voroi59 , 1.0 );
			float height107_g7 = temp_output_62_0;
			float scale107_g7 = 0.5;
			float3 localPerturbNormal107_g7 = PerturbNormal107_g7( surf_pos107_g7 , surf_norm107_g7 , height107_g7 , scale107_g7 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g7 = mul( ase_worldToTangent, localPerturbNormal107_g7);
			float3 NormalMap137 = worldToTangentDir42_g7;
			o.Normal = NormalMap137;
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float4 appendResult156 = (float4(_WaveDirectionX , _WaveDirectionY , 0.0 , 0.0));
			float4 appendResult159 = (float4((0.02 + (_WaveDirectionX - 0.0) * (0.15 - 0.02) / (1.0 - 0.0)) , (0.02 + (_WaveDirectionY - 0.0) * (0.15 - 0.02) / (1.0 - 0.0)) , 0.0 , 0.0));
			float4 WaveTileUV23 = ( ( WorldSpaceTile11 * appendResult159 ) * _WaveTile );
			float2 panner2 = ( temp_output_7_0 * appendResult156.xy + WaveTileUV23.xy);
			float simplePerlin2D1 = snoise( panner2 );
			float2 panner27 = ( temp_output_7_0 * appendResult156.xy + ( WaveTileUV23 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D26 = snoise( panner27 );
			float WavePattern34 = ( simplePerlin2D1 + simplePerlin2D26 );
			float clampResult88 = clamp( WavePattern34 , 0.0 , 1.0 );
			float4 Albedo124 = ( _WaterColor + ( _WaveColor * temp_output_62_0 ) + ( clampResult88 * _WaveColor2 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float3 WaveHeight32 = ( ( float3(0,1,0) * _Height ) * simplePerlin2D1 );
			float4 screenColor119 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( ( temp_output_62_0 * 1.3 ) * WaveHeight32 * temp_output_62_0 ) ).xy);
			float4 clampResult122 = clamp( screenColor119 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Refraction123 = clampResult122;
			o.Albedo = ( Albedo124 * Refraction123 ).rgb;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth96 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth96 = abs( ( screenDepth96 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float4 clampResult103 = clamp( ( ( ( 1.0 - distanceDepth96 ) + tex2D( _FoamTexture, ( ( WorldSpaceTile11 / 10.0 ) * 1.0 ).xy ) ) * _EdgePower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Edge101 = clampResult103;
			o.Emission = Edge101.rgb;
			o.Smoothness = 0.9;
			o.Alpha = 1;
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=18707
0;285;1827;914;1428.583;584.2787;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;12;-3613.858,-588.6812;Inherit;False;611.7109;233;Comment;3;10;9;11;World Spave UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-3563.858,-538.6812;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;10;-3371.038,-538.6812;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-4306.988,271.9753;Inherit;False;Property;_WaveDirectionY;WaveDirectionY;13;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-4300.988,131.9753;Inherit;False;Property;_WaveDirectionX;WaveDirectionX;12;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;157;-3884.136,-9.200714;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.02;False;4;FLOAT;0.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;158;-3891.136,169.7993;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.02;False;4;FLOAT;0.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3231.148,-534.9003;Inherit;False;WorldSpaceTile;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;24;-3627.192,-327.9182;Inherit;False;1995.586;604.6493;Wave UVs and Height;11;23;16;14;17;13;33;32;31;21;22;159;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-3577.192,-277.9184;Inherit;True;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;159;-3584.737,2.637615;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3266.336,-0.4287598;Inherit;True;Property;_WaveTile;WaveTile;2;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-3287.992,-246.3971;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-3012.919,-236.5317;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;36;-3386.723,322.3345;Inherit;False;1762.762;638.7646;Wave Pattern;13;8;4;29;7;25;2;28;27;1;26;30;34;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-3324.781,702.7318;Inherit;False;Property;_WaveSpeed;WaveSpeed;0;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-3331.126,623.5388;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-2718.957,-235.2407;Inherit;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-3132.228,673.1482;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;125;-1881.5,-1354.026;Inherit;False;2101.16;973.6204;Comment;16;57;71;88;86;54;55;56;92;59;60;61;62;64;65;80;124;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-3335.895,831.8931;Inherit;False;23;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-3336.723,395.4453;Inherit;False;23;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;156;-3589.6,519.8758;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;2;-2704.895,405.334;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;21;-2792.136,-56.84635;Inherit;False;Constant;_WaveUp;WaveUp;3;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;55;-1719.317,-890.0181;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2679.199,115.2619;Inherit;False;Property;_Height;Height;7;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-3086.831,833.647;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1785.479,-816.1724;Inherit;False;Property;_SmallWaveSpeed;SmallWaveSpeed;6;0;Create;True;0;0;False;0;False;1;0.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1480.116,-892.8102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-2389.146,372.3344;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;27;-2707.833,673.2744;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1649.576,-722.0352;Inherit;False;Property;_WaveSize;Wave Size;8;0;Create;True;0;0;False;0;False;1;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1714.168,-1017.781;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2412.026,28.19053;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2142.391,-67.07094;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;113;-1546.349,1095.521;Inherit;False;1320.087;670.7841;EdgeFoam;8;112;106;109;107;111;108;110;105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;26;-2378.205,663.8694;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1235.911,-769.7771;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;59;-1295.374,-936.9504;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1894.093,-104.8916;Inherit;True;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;151;289.7883,916.7679;Inherit;False;Constant;_Float2;Float 2;12;0;Create;True;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-1535.214,619.4531;Inherit;False;1602.835;312.3528;Edge;7;101;103;99;98;100;96;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-2051.705,559.6223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1481.631,1589.26;Inherit;False;Constant;_Float5;Float 5;12;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;62;-1046.801,-875.207;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1536.826,1484.644;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;295.6988,1139.577;Inherit;True;32;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1380.341,1682.769;Inherit;False;Constant;_EdgeFoamTile;EdgeFoamTile;12;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-1485.214,669.4532;Inherit;False;Property;_EdgeDistance;EdgeDistance;10;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;461.9958,832.509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1891.302,466.6074;Inherit;True;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;115;557.7591,582.29;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;111;-1302.631,1488.26;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1124.631,1534.26;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;779.6622,1010.073;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;96;-1269.545,672.4204;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;116;792.7476,685.7014;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-1082.707,-611.4413;Inherit;True;34;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;107;-1239.901,1186.894;Inherit;True;Property;_FoamTexture;FoamTexture;11;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;148;-1002.35,-403.7504;Inherit;False;Property;_WaveColor2;WaveColor2;4;0;Create;True;0;0;False;0;False;0,0.1882353,0.4156863,1;0.2202741,0.7019608,0.8490566,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;98;-975.4093,692.7062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;987.5455,884.4341;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;106;-947.8337,1185.429;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;88;-797.6129,-644.535;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-1105.038,-1151.662;Inherit;False;Property;_WaveColor;WaveColor;3;0;Create;True;0;0;False;0;False;0,0.1882353,0.4156863,1;0.2202741,0.7019608,0.8490566,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-546.1374,1159.542;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;64;-761.2403,-1161.074;Inherit;False;Property;_WaterColor;WaterColor;1;0;Create;True;0;0;False;0;False;0.001957997,0.1867146,0.4150943,0;0.001957997,0.1867146,0.4150943,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;119;1206.118,841.3989;Inherit;False;Global;_GrabScreen0;Grab Screen 0;12;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-690.0839,-941.724;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-910.8653,829.0589;Inherit;False;Property;_EdgePower;EdgePower;9;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-550.4955,-613.5606;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-556.1904,701.6772;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;122;1436.019,852.724;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-278.0836,-1015.061;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;143;-450.9034,-329.3307;Inherit;True;Normal From Height;-1;;7;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;0.5;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;1608.16,869.7116;Inherit;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;103;-380.0945,696.6768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;-4.34025,-1043.011;Inherit;True;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-198.1161,698.7106;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;516.5988,-532.1729;Inherit;False;124;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;516.5986,-429.402;Inherit;False;123;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-54.59407,-307.4507;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;739.6646,-483.5627;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;555.9258,215.4332;Inherit;True;Property;_Tesselation;Tesselation;5;0;Create;True;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1233.944,-309.746;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;147;641.1961,1215.533;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;290.9714,1351.725;Inherit;False;137;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;117;290.8923,1054.598;Inherit;False;Constant;_RefactAmount;RefactAmount;12;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-3335.809,476.5897;Inherit;False;Constant;_WaveDirection;WaveDirection;1;0;Create;True;0;0;False;0;False;1,1;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;35;533.1216,-17.80185;Inherit;True;32;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;37;546.5482,-193.4671;Inherit;False;Constant;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;343.2345,-347.5659;Inherit;False;137;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;545.9996,-273.4342;Inherit;False;101;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;925.7457,-348.3495;Float;False;True;-1;6;;0;0;Standard;Custom/OceanWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;1
WireConnection;10;1;9;3
WireConnection;157;0;152;0
WireConnection;158;0;153;0
WireConnection;11;0;10;0
WireConnection;159;0;157;0
WireConnection;159;1;158;0
WireConnection;14;0;13;0
WireConnection;14;1;159;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;23;0;16;0
WireConnection;7;0;8;0
WireConnection;7;1;4;0
WireConnection;156;0;152;0
WireConnection;156;1;153;0
WireConnection;2;0;25;0
WireConnection;2;2;156;0
WireConnection;2;1;7;0
WireConnection;28;0;29;0
WireConnection;56;0;55;0
WireConnection;56;1;54;0
WireConnection;1;0;2;0
WireConnection;27;0;28;0
WireConnection;27;2;156;0
WireConnection;27;1;7;0
WireConnection;22;0;21;0
WireConnection;22;1;31;0
WireConnection;33;0;22;0
WireConnection;33;1;1;0
WireConnection;26;0;27;0
WireConnection;59;0;92;0
WireConnection;59;1;56;0
WireConnection;59;2;57;0
WireConnection;32;0;33;0
WireConnection;30;0;1;0
WireConnection;30;1;26;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;150;0;62;0
WireConnection;150;1;151;0
WireConnection;34;0;30;0
WireConnection;111;0;105;0
WireConnection;111;1;110;0
WireConnection;109;0;111;0
WireConnection;109;1;108;0
WireConnection;118;0;150;0
WireConnection;118;1;121;0
WireConnection;118;2;62;0
WireConnection;96;0;97;0
WireConnection;116;0;115;0
WireConnection;98;0;96;0
WireConnection;120;0;116;0
WireConnection;120;1;118;0
WireConnection;106;0;107;0
WireConnection;106;1;109;0
WireConnection;88;0;71;0
WireConnection;112;0;98;0
WireConnection;112;1;106;0
WireConnection;119;0;120;0
WireConnection;65;0;61;0
WireConnection;65;1;62;0
WireConnection;86;0;88;0
WireConnection;86;1;148;0
WireConnection;99;0;112;0
WireConnection;99;1;100;0
WireConnection;122;0;119;0
WireConnection;80;0;64;0
WireConnection;80;1;65;0
WireConnection;80;2;86;0
WireConnection;143;20;62;0
WireConnection;123;0;122;0
WireConnection;103;0;99;0
WireConnection;124;0;80;0
WireConnection;101;0;103;0
WireConnection;137;0;143;40
WireConnection;128;0;126;0
WireConnection;128;1;127;0
WireConnection;147;0;121;0
WireConnection;0;0;128;0
WireConnection;0;1;136;0
WireConnection;0;2;102;0
WireConnection;0;4;37;0
WireConnection;0;11;35;0
WireConnection;0;14;20;0
ASEEND*/
//CHKSM=702CD75EB08FE56EC9DF2836CBC53EA0A397B44B