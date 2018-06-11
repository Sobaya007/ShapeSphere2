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

        auto time = 0;
        Core().addProcess({
            if (time++ % 100 == 0) {
                explode();
            }
        }, "explode");
    }

    void explode() {
        //爆発

        // パーティクル
        // 黒い岩
        // 炎

        // 爆炎
        import std.random;

        void stone() {
            auto entity = makeEntity(Dodecahedron.create(), new ColorMaterial(vec3(0)));
            entity.scale = vec3(0.1);
            this.addChild(entity);
            auto vel = vec3(uniform(-1.5, +1.5), uniform(0.5, 1.5), uniform(-1.5, +1.5)) * 0.1;
            Core().addProcess((proc){
                entity.pos += vel; 
                vel += vec3(0, -0.1, 0) * 0.1;
                entity.scale -= vec3(0.01);
                if (entity.scale.x <= 0) {
                    entity.remove();
                    proc.kill();
                }
            }, "stone");
        }

        foreach (i; 0..10) {
            stone();
        }
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
