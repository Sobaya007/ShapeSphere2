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
        this.initializeConfig();
        auto entity = makeEntity(Dodecahedron.create(), new BombMaterial);
        auto light = new PointLight(vec3(0), vec3(0));
        light.visible = false;
        entity.buildSphere();
        entity.addChild(light);
        this.entity = entity;
        this.scale *= 3;

        this.entity.addProcess({
            auto s1 = sin(entity.time * 0.03) * 0.4 + 0.6;
            auto s2 = cos(entity.time * 0.0433456781) * 0.4 + 0.6;
            entity.lightScale = (s1 + s2) / 2;
            light.diffuse = vec3(1, 0.7, 0.1) * entity.lightScale;
        });

        auto time = 0;
        this.entity.addProcess({
            if (time++ % 200 == 0) {
                //explode();
            }
        });
    }

    import dconfig;

    mixin HandleConfig;

    @config(ConfigPath("stone.json"))  {
        float STONE_SIZE;
        float VEL_RANGE_XZ;
        float VEL_MIN_Y;
        float VEL_MAX_Y;
        float GRAVITY;
        float SIZE_SPEED;
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
            entity.scale = vec3(STONE_SIZE);
            this.addChild(entity);
            vec3 vel;
            vel.xz = vec2(uniform(-VEL_RANGE_XZ, +VEL_RANGE_XZ));
            vel.y = uniform(VEL_MIN_Y, VEL_MAX_Y);
            entity.addProcess({
                entity.pos += vel; 
                vel += vec3(0, -GRAVITY, 0);
                entity.scale -= vec3(SIZE_SPEED);
                if (entity.scale.x <= 0) {
                    import std.stdio;
                    writeln("explosin finished");
                    writeln("removing...");
                    entity.remove();
                    writeln("destroying..");
                    entity.destroy();
                }
            });
        }

        auto light = new PointLight(vec3(0), vec3(0));
        entity.addChild(light);

        AnimationManager().startAnimation(
            sequence(
                animation(
                    (float t) {
                        light.diffuse = vec3(t);
                    },
                    setting(
                        0.0f,
                        10,
                        100.frame,
                        &Ease.linear
                    )
                ),
                single({foreach(i; 0..10) stone();}),
                animation(
                    (float t) {
                        light.diffuse = vec3(t);
                    },
                    setting(
                        10f,
                        0,
                        10.frame,
                        &Ease.linear
                    )
                ),
            )
        );
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
