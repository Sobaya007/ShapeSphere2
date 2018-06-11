module game.stage.crystalMine.component.Bomb;

import sbylib;
import std.math;
import game.stage.crystalMine.component.Component;

struct Bomb {
    mixin Component!(BombEntity, ["pos" : "vec3"]);
}

class BombEntity {
    Entity entity;

    alias entity this;

    this() {
        auto entity = makeEntity(Dodecahedron.create(), new BombMaterial);
        auto light = new PointLight(vec3(0), vec3(0));
        light.visible = false;
        entity.buildSphere();
        entity.addChild(light);
        this.entity = entity;
        this.scale *= 3;

        Core().addProcess({
            auto s1 = sin(entity.time * 0.03) * 0.4 + 0.6;
            auto s2 = cos(entity.time * 0.0433456781) * 0.4 + 0.6;
            entity.lightScale = (s1 + s2) / 2;
            light.diffuse = vec3(1, 0.7, 0.1) * entity.lightScale;
        }, "bomb");
    }
}

class BombMaterial : Material {
    mixin ConfigureMaterial!(q{{"useGeometryShader" : true}});

    utexture noise;
    ufloat time;
    ufloat lightScale;

    this() {
        mixin(autoAssignCode);
        super();

        this.noise = ImageLoader.load(ImagePath("noise.jpg")).generateTexture();
        this.time = 0;
        Core().addProcess({ this.time++; }, "bomb");
        this.lightScale = 1;
    }
}
