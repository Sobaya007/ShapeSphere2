module model.xfile.node.XMaterial;

import sbylib.math.Vector;

import model.xfile.node;

struct XMaterial {
    string name;
    vec4 faceColor;
    float power;
    vec3 specularColor;
    vec3 emissiveColor;
    XTextureFilename textureFileName;
}
