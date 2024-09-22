// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/PoliceCarLights"
{
	Properties
	{
		_Albedo1("Albedo", 2D) = "white" {}
		_AlbedoColor1("AlbedoColor", Color) = (1,1,1,0)
		[Normal]_Normal1("Normal", 2D) = "bump" {}
		_Metallic1("Metallic", 2D) = "white" {}
		_MetalicSmoothness1("MetalicSmoothness", Range( 0 , 1)) = 1
		_EmissionRedMask("EmissionRedMask", 2D) = "white" {}
		_EmissionBlueMask("EmissionBlueMask", 2D) = "white" {}
		[Toggle]_ToggleEmission1("Toggle Emission", Float) = 0
		[HDR]_EmissionRed("EmissionRed", Color) = (1,1,1,0)
		[HDR]_EmissionBlue("EmissionBlue", Color) = (1,1,1,0)
		_EmissionStrenght1("EmissionStrenght", Range( 0 , 10)) = 0
		_Stroke1("Stroke", Range( 0 , 10)) = 3
		_StrokeColor1("StrokeColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		
		
		
		struct Input
		{
			half filler;
		};
		uniform float4 _StrokeColor1;
		uniform float _Stroke1;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = (0.0 + (_Stroke1 - 0.0) * (0.1 - 0.0) / (10.0 - 0.0));
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _StrokeColor1.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal1;
		uniform float4 _Normal1_ST;
		uniform float4 _AlbedoColor1;
		uniform sampler2D _Albedo1;
		uniform float4 _Albedo1_ST;
		uniform float _ToggleEmission1;
		uniform float4 _EmissionRed;
		uniform sampler2D _EmissionRedMask;
		uniform float4 _EmissionRedMask_ST;
		uniform float4 _EmissionBlue;
		uniform sampler2D _EmissionBlueMask;
		uniform float4 _EmissionBlueMask_ST;
		uniform float _EmissionStrenght1;
		uniform float _MetalicSmoothness1;
		uniform sampler2D _Metallic1;
		uniform float4 _Metallic1_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal1 = i.uv_texcoord * _Normal1_ST.xy + _Normal1_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal1, uv_Normal1 ) );
			float2 uv_Albedo1 = i.uv_texcoord * _Albedo1_ST.xy + _Albedo1_ST.zw;
			o.Albedo = ( _AlbedoColor1 * tex2D( _Albedo1, uv_Albedo1 ) ).rgb;
			float2 uv_EmissionRedMask = i.uv_texcoord * _EmissionRedMask_ST.xy + _EmissionRedMask_ST.zw;
			float2 uv_EmissionBlueMask = i.uv_texcoord * _EmissionBlueMask_ST.xy + _EmissionBlueMask_ST.zw;
			float mulTime24 = _Time.y * 10.0;
			float clampResult29 = clamp( step( sin( mulTime24 ) , 0.0 ) , 0.0 , 1.0 );
			float4 lerpResult19 = lerp( ( _EmissionRed * tex2D( _EmissionRedMask, uv_EmissionRedMask ) ) , ( _EmissionBlue * tex2D( _EmissionBlueMask, uv_EmissionBlueMask ) ) , clampResult29);
			o.Emission = (( _ToggleEmission1 )?( ( lerpResult19 * _EmissionStrenght1 ) ):( float4( 0,0,0,0 ) )).rgb;
			float2 uv_Metallic1 = i.uv_texcoord * _Metallic1_ST.xy + _Metallic1_ST.zw;
			o.Smoothness = ( _MetalicSmoothness1 * tex2D( _Metallic1, uv_Metallic1 ) ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18707
0;285;1827;914;3070.95;-136.8695;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;26;-2459.313,564.5144;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-2208.606,566.3051;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;28;-1973.692,557.884;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-2133.138,-306.9334;Inherit;False;Property;_EmissionRed;EmissionRed;9;1;[HDR];Create;True;0;0;False;0;False;1,1,1,0;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;31;-1771.45,596.8695;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2184.717,-126.8174;Inherit;True;Property;_EmissionRedMask;EmissionRedMask;6;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-2147.037,93.3766;Inherit;False;Property;_EmissionBlue;EmissionBlue;10;1;[HDR];Create;True;0;0;False;0;False;1,1,1,0;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-2198.615,273.4925;Inherit;True;Property;_EmissionBlueMask;EmissionBlueMask;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1753.765,237.988;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;29;-1633.801,366.3684;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1739.867,-162.3219;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1250.251,356.4772;Inherit;False;Property;_EmissionStrenght1;EmissionStrenght;11;0;Create;True;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-345.3892,523.2916;Inherit;False;Property;_Stroke1;Stroke;12;0;Create;True;0;0;False;0;False;3;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;19;-1381.305,11.79936;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-26.54074,527.9249;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-240.3467,-782.3704;Inherit;False;Property;_AlbedoColor1;AlbedoColor;1;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-262.0593,-576.4056;Inherit;True;Property;_Albedo1;Albedo;0;0;Create;True;0;0;False;0;False;-1;None;d6018251420b9d84b86e227b45d5ffbb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-129.8956,118.9462;Inherit;True;Property;_Metallic1;Metallic;4;0;Create;True;0;0;False;0;False;-1;None;c720748abdee74f4c9235dfa5fd00f88;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-952.6075,46.60368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-129.9296,-2.351595;Inherit;False;Property;_MetalicSmoothness1;MetalicSmoothness;5;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-103.3893,334.2916;Inherit;False;Property;_StrokeColor1;StrokeColor;13;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;271.1086,-2.351534;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;17;203.914,412.2996;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;14;-695.4582,-130.1056;Inherit;False;Property;_ToggleEmission1;Toggle Emission;8;0;Create;True;0;0;False;0;False;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;18;-786.4678,-433.5211;Inherit;True;Property;_Normal1;Normal;2;1;[Normal];Create;True;0;0;False;0;False;-1;None;07a0a56ef9399fe42a813194ec88c7cb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;118.8992,-634.8404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1100.287,-347.4188;Inherit;False;Property;_NormalStrenght1;NormalStrenght;3;0;Create;True;0;0;False;0;False;1;1;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;470,-198;Float;False;True;-1;2;;0;0;Standard;Custom/PoliceCarLights;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;26;0
WireConnection;28;0;24;0
WireConnection;31;0;28;0
WireConnection;21;0;22;0
WireConnection;21;1;20;0
WireConnection;29;0;31;0
WireConnection;5;0;3;0
WireConnection;5;1;2;0
WireConnection;19;0;5;0
WireConnection;19;1;21;0
WireConnection;19;2;29;0
WireConnection;8;0;1;0
WireConnection;12;0;19;0
WireConnection;12;1;11;0
WireConnection;16;0;6;0
WireConnection;16;1;7;0
WireConnection;17;0;4;0
WireConnection;17;1;8;0
WireConnection;14;1;12;0
WireConnection;13;0;10;0
WireConnection;13;1;9;0
WireConnection;0;0;13;0
WireConnection;0;1;18;0
WireConnection;0;2;14;0
WireConnection;0;4;16;0
WireConnection;0;11;17;0
ASEEND*/
//CHKSM=19D6C391C4B846BAF836F5E75209843090CE9255