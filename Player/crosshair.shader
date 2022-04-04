shader_type canvas_item;

uniform bool center_enabled = true;
uniform bool legs_enabled = false;
uniform bool inverted = false;
uniform vec4 color = vec4(1, 1, 1, 1.0);
uniform float center_radius = 0.001;
uniform float width = 0.001;
uniform float len = 0.01;
uniform float spacing = 0.01;
uniform float spread = 1.0;

void fragment(){
	float a = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 UVa = vec2(UV.x / a, UV.y);
	vec2 center = vec2(0.5 / a, 0.5);

	float point = step(distance(UVa, center), center_radius);

	float h = step(center.x - len - spacing*spread, UVa.x) - step(center.x - spacing*spread, UVa.x);
	h += step(center.x + spacing*spread, UVa.x) - step(center.x + len + spacing*spread, UVa.x);
	h *= step(center.y - width, UVa.y) - step(center.y + width, UVa.y);
	
	float v = step(center.y - len - spacing*spread, UVa.y) - step(center.y - spacing*spread, UVa.y);
	v += step(center.y + spacing*spread, UVa.y) - step(center.y + len + spacing*spread, UVa.y);
	v *= step(center.x - width, UVa.x) - step(center.x + width, UVa.x);

	float crosshair;

	crosshair = (h+v) * float(legs_enabled) + point * float(center_enabled);

	if(!inverted){
		COLOR = color * crosshair;
	}else{
		COLOR = vec4((cos(textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb * 3.1415926534) + 1.0)/2.0, 1.0) * crosshair;
	}
}