module model.xfile.loader.XMaterial;

import sbylib;

class XMaterial {
    vec4 diffuse;
    vec3 specular;
    vec3 ambient;
    float power;

    private bool _hasTexture = false;
    private string _textureFileName;

    bool hasTexture() {
        return _hasTexture;
    }

    void setTectureFileName(string name) {
        this._hasTexture = true;
        this._textureFileName = name;
    }

    string getTextureFileName() {
        return _textureFileName;
    }

    Material buildMaterial() {
        if (hasTexture()) {
            PhongTextureMaterial material = new PhongTextureMaterial;
            material.diffuse = this.diffuse.xyz;
            material.specular = this.specular;
            material.ambient = vec4(this.ambient, 1.0);
            material.power = this.power;
            material.texture = Utils.generateTexture(ImageLoader.load(ImagePath(getTextureFileName)));
            return material;
        } else {
            PhongMaterial material = new PhongMaterial;
            material.diffuse = this.diffuse.xyz;
            material.specular = this.specular;
            material.ambient = vec4(this.ambient, 1.0);
            material.power = this.power;
            return material;
        }
    }

    override string toString() {
        return toString(0);
    }

    string toString(int depth) {
        import std.format, std.range, std.array, std.functional;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMaterial(\n%sdiffuse: %s,\n%sspecular: %s,\n%sambient: %s,\n%spower: %s\n%s)".format(
            tab2,
            this.diffuse,
            tab2,
            this.specular,
            tab2,
            this.ambient,
            tab2,
            this.power,
            tab1
        );
    }
}
