module sbylib.model.xfile.loader.XMaterial;

import sbylib;

interface MaterialBuilder {
    Material buildMaterial(immutable(XMaterial));
}

class DefaultMaterialBuilder : MaterialBuilder {

    override Material buildMaterial(immutable(XMaterial) xmat) {
        if (xmat.textureFileName.isJust) {
            PhongTextureMaterial material = new PhongTextureMaterial;
            material.diffuse = xmat.diffuse.xyz;
            material.specular = xmat.specular;
            material.ambient = vec4(xmat.ambient, 1.0);
            material.power = xmat.power;
            material.texture = generateTexture(ImageLoader.load(ImagePath(xmat.textureFileName.unwrap())));
            return material;
        } else {
            PhongMaterial material = new PhongMaterial;
            material.diffuse = xmat.diffuse.xyz;
            material.specular = xmat.specular;
            material.ambient = vec4(xmat.ambient, 1.0);
            material.power = xmat.power;
            return material;
        }
    }
}

immutable class XMaterial {
immutable:
    vec4 diffuse;
    vec3 specular;
    vec3 ambient;
    float power;
    string name;
    Maybe!string textureFileName;

    this(vec4 diffuse, vec3 specular, vec3 ambient, float power, string name, string textureFileName) {
        this.diffuse = diffuse;
        this.specular = specular;
        this.ambient = ambient;
        this.power = power;
        this.name = name;
        this.textureFileName = Just(textureFileName);
    }

    this(vec4 diffuse, vec3 specular, vec3 ambient, float power, string name) {
        this.diffuse = diffuse;
        this.specular = specular;
        this.ambient = ambient;
        this.power = power;
        this.name = name;
        this.textureFileName = None!string;
    }

    string toString() {
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
