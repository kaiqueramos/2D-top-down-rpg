shader_type canvas_item;

uniform sampler2D toneMapping;
uniform sampler2D lifetimeGradient;

void fragment() {
	float particleLife = COLOR.r;
	vec4 baseColor = texture(TEXTURE, UV);
	baseColor.rgb = texture(toneMapping, baseColor.rr).rgb;
	float appearenceState = particleLife * 2.0 - UV.x * 0.3;
	
	if (appearenceState > 0.0){
		COLOR = texture(lifetimeGradient, vec2(appearenceState)) * baseColor;
	} else {
		COLOR.a = 0.0;
	}
}
