#vertex Proj

uniform bool condition;
require Shader TrueMaterial;
require Shader FalseMaterial;

void main() {
    vec4 color;
    if (condition) {
        TrueMaterial(color);
    } else {
        FalseMaterial(color);
    }
    fragColor = color;
}
