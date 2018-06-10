module game.entity.Bomb;

import sbylib;
import std.math;

class Bomb {
    Entity entity;

    alias entity this;

    this() {
        auto entity = makeEntity(Dodecahedron.create(), new BombMaterial);
        this.entity = entity;
        this.scale *= 5;
    }
}

class BombMaterial : Material {
    mixin ConfigureMaterial!(q{{"useGeometryShader" : true}});

    utexture noise;
    ufloat time;

    this() {
        mixin(autoAssignCode);
        super();

        this.noise = ImageLoader.load(ImagePath("noise.jpg")).generateTexture();
        this.time = 0;
        Core().addProcess({ this.time++; }, "bomb");
    }
}
