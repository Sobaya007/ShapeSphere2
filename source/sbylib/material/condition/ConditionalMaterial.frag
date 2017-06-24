#vertex Proj

uniform bool condition;
uniform vec3 trueColor;
uniform vec3 falseColor;

void main() {
    fragColor = vec4(condition ? trueColor : falseColor, 1);
}
