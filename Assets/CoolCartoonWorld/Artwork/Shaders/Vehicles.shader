// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Vehicles"
{
	Properties
	{
		_Stroke("Stroke", Range( 0 , 10)) = 1
		_StrokeColor("StrokeColor", Color) = (0,0,0,0)
		_Color("Color", 2D) = "white" {}
		_MainColorMask("MainColorMask", 2D) = "white" {}
		_EmissionMask("EmissionMask", 2D) = "white" {}
		_SmoothnesMask("SmoothnesMask", 2D) = "white" {}
		_MainColor("MainColor", Color) = (0,0,0,0)
		_EmissionStrenght("EmissionStrenght", Range( 0 , 1)) = 0
		_SmoothnesStrenght("SmoothnesStrenght", Range( 0 , 1)) = 1
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
		uniform float4 _StrokeColor;
		uniform float _Stroke;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = (0.0 + (_Stroke - 0.0) * (0.1 - 0.0) / (10.0 - 0.0));
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _StrokeColor.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _MainColor;
		uniform sampler2D _MainColorMask;
		uniform float4 _MainColorMask_ST;
		uniform sampler2D _Color;
		uniform float4 _Color_ST;
		uniform float _EmissionStrenght;
		uniform sampler2D _EmissionMask;
		uniform float4 _EmissionMask_ST;
		uniform sampler2D _SmoothnesMask;
		uniform float4 _SmoothnesMask_ST;
		uniform float _SmoothnesStrenght;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainColorMask = i.uv_texcoord * _MainColorMask_ST.xy + _MainColorMask_ST.zw;
			float4 tex2DNode8 = tex2D( _MainColorMask, uv_MainColorMask );
			float2 uv_Color = i.uv_texcoord * _Color_ST.xy + _Color_ST.zw;
			float4 tex2DNode5 = tex2D( _Color, uv_Color );
			o.Albedo = ( ( _MainColor * tex2DNode8 ) + ( tex2DNode5 * ( 1.0 - tex2DNode8 ) ) ).rgb;
			float2 uv_EmissionMask = i.uv_texcoord * _EmissionMask_ST.xy + _EmissionMask_ST.zw;
			o.Emission = ( _EmissionStrenght * tex2D( _EmissionMask, uv_EmissionMask ) * tex2DNode5 ).rgb;
			float2 uv_SmoothnesMask = i.uv_texcoord * _SmoothnesMask_ST.xy + _SmoothnesMask_ST.zw;
			o.Smoothness = ( tex2D( _SmoothnesMask, uv_SmoothnesMask ) * _SmoothnesStrenght ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18707
0;285;1827;914;4080.796;1304.589;2.998104;True;False
Node;AmplifyShaderEditor.SamplerNode;8;-1185.46,-576.5935;Inherit;True;Property;_MainColorMask;MainColorMask;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;11;-855.385,-647.2921;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1363.15,756.8242;Inherit;False;Property;_Stroke;Stroke;0;0;Create;True;0;0;False;0;False;1;0.03;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1191.933,-821.8632;Inherit;True;Property;_Color;Color;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-1156.66,-384.5939;Inherit;False;Property;_MainColor;MainColor;6;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-1177.466,-78.47594;Inherit;True;Property;_EmissionMask;EmissionMask;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1163.073,-177.3575;Inherit;False;Property;_EmissionStrenght;EmissionStrenght;7;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;3;-1044.301,761.4575;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-555.061,-504.5938;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-1121.15,567.8243;Inherit;False;Property;_StrokeColor;StrokeColor;1;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-713.9527,53.01167;Inherit;True;Property;_SmoothnesMask;SmoothnesMask;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-715.6602,251.1037;Inherit;False;Property;_SmoothnesStrenght;SmoothnesStrenght;8;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-567.8614,-703.7935;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-337.4616,-622.193;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-591.4675,-240.4297;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;4;-813.8467,645.8323;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-273.3689,-34.0806;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;146.8614,-169.0613;Float;False;True;-1;2;;0;0;Standard;Custom/Vehicles;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;8;0
WireConnection;3;0;1;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;10;0;5;0
WireConnection;10;1;11;0
WireConnection;14;0;7;0
WireConnection;14;1;10;0
WireConnection;17;0;18;0
WireConnection;17;1;15;0
WireConnection;17;2;5;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;0;0;14;0
WireConnection;0;2;17;0
WireConnection;0;4;23;0
WireConnection;0;11;4;0
ASEEND*/
//CHKSM=2913D47C15088825D54C64E275B74FF72766D07F