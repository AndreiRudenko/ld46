// adapted from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
#version 450

uniform sampler2D tex;
uniform float blur;
uniform vec2 dir;

in vec2 tcoord;
in vec4 color;

out vec4 FragColor;

void main() {
	vec4 sum = vec4(0.0);

	// gaussian
	sum += texture(tex, vec2(tcoord.x - 4.0*blur*dir.x, tcoord.y - 4.0*blur*dir.y)) * 0.0162162162;
	sum += texture(tex, vec2(tcoord.x - 3.0*blur*dir.x, tcoord.y - 3.0*blur*dir.y)) * 0.0540540541;
	sum += texture(tex, vec2(tcoord.x - 2.0*blur*dir.x, tcoord.y - 2.0*blur*dir.y)) * 0.1216216216;
	sum += texture(tex, vec2(tcoord.x - 1.0*blur*dir.x, tcoord.y - 1.0*blur*dir.y)) * 0.1945945946;

	sum += texture(tex, vec2(tcoord.x, tcoord.y)) * 0.2270270270;

	sum += texture(tex, vec2(tcoord.x + 1.0*blur*dir.x, tcoord.y + 1.0*blur*dir.y)) * 0.1945945946;
	sum += texture(tex, vec2(tcoord.x + 2.0*blur*dir.x, tcoord.y + 2.0*blur*dir.y)) * 0.1216216216;
	sum += texture(tex, vec2(tcoord.x + 3.0*blur*dir.x, tcoord.y + 3.0*blur*dir.y)) * 0.0540540541;
	sum += texture(tex, vec2(tcoord.x + 4.0*blur*dir.x, tcoord.y + 4.0*blur*dir.y)) * 0.0162162162;

	FragColor = color * sum;
}