#vertex Proj

uniform bool condition;
require Shader TrueMaterial;
require Shader FalseMaterial;

void main() {
    if (condition) {
        TrueMaterial(fragColor);
    } else {
        FalseMaterial(fragColor);
    }
}
