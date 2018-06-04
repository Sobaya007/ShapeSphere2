module game.effect.StartEffect;

import game.Game;
import game.effect.Effect;
import sbylib;
import dconfig;

class StartEffect {

    mixin HandleConfig;

    alias StartEffectEntity = TypedEntity!(TypedGeometry!([Attribute.Position, Attribute.UV], Prim.Point), StartEffectMaterial);
    StartEffectEntity entity;
    Fragment[] fragmentList;
    IAnimationWithPeriod anim;
    alias anim this;

    @config(ConfigPath("StartEffect.json")) {
        uint PERIOD;
        uint WAIT_PERIOD;
        float WIND;
        float NOISE;
    }

    this(string str) {
        this.initializeConfig();
        const viewport = Game.getScene().viewport;
        const screenAspect = viewport.getWidth / viewport.getHeight;
        const FRAG_HEIGHT = 0.01;
        const FRAG_WIDTH = FRAG_HEIGHT * Core().getWindow.getHeight / Core().getWindow.getWidth;
        auto mat = new StartEffectMaterial(str);
        const W = 1.5;
        const H = W / mat.aspectRatio;
        auto X_DIV = W/FRAG_WIDTH;
        auto Y_DIV = H/FRAG_HEIGHT;
        debug {
            mat.sizeInPixel = FRAG_HEIGHT * Core().getWindow.getHeight * 0.5;
            mat.fragWidth = FRAG_WIDTH/W;
            mat.fragHeight = FRAG_HEIGHT/H;
        } else {
            mat.sizeInPixel = FRAG_HEIGHT * Core().getWindow.getHeight * 1.0;
            mat.fragWidth = FRAG_WIDTH/W * 2;
            mat.fragHeight = FRAG_HEIGHT/H * 2;
        }

        VertexT[] vertices;
        foreach (i; 0..X_DIV) {
            auto u1 = i / X_DIV;
            auto x1 = (u1-0.5)*W + FRAG_WIDTH/2;
            foreach (j; 0..Y_DIV) {
                auto v1 = j / Y_DIV;
                auto y1 = (v1-0.5)*H + FRAG_HEIGHT/2;
                auto vertex = new VertexT(vec3(x1,y1,1), vec2(u1,v1));
                vertices ~= vertex;
                fragmentList ~= Fragment(vertex, WIND, NOISE);
            }
        }
        auto geom = new TypedGeometry!([Attribute.Position, Attribute.UV], Prim.Point)(vertices);
        this.entity = makeEntity(geom, mat);
        Game.getWorld2D().add(entity);

        this.anim = sequence(
            multi(
                animation((float alpha) => mat.textAlpha = alpha, setting(0.0f, 1.0f, PERIOD.frame, &Ease.linear)),
                animation((float lineRate) => mat.lineRate = lineRate, setting(0.0f, 1.0f, PERIOD.frame, &Ease.linear)),
            ),
            wait(WAIT_PERIOD.frame),
            multi(
                animation((void delegate() kill) {
                    foreach (ref frag; fragmentList) {
                        frag.step();
                    }
                    entity.mesh.geom.updateBuffer();
                    if (entity.mat.textAlpha.value == 0) kill();
                }, true),
                animation((float alpha) => mat.textAlpha = alpha, setting(1.0f, 0.0f, 100.frame, &Ease.linear))
            )
        );
    }

    void abridge() {
        this.anim = sequence(
            multi(
                animation((void delegate() kill) {
                    foreach (ref frag; fragmentList) {
                        frag.step();
                    }
                    entity.mesh.geom.updateBuffer();
                    if (entity.mat.textAlpha.value == 0) kill();
                }, true),
                animation((float alpha) => entity.mat.textAlpha = alpha, setting(entity.mat.textAlpha, 0.0f, 50.frame, &Ease.linear))
            )
        );
    }

    private struct Fragment {
        VertexT vertex;
        vec2 vel;
        float time;
        float wind;
        float noise;

        this(VertexT vertex, float wind, float noise) {
            this.vertex = vertex;
            vel = vec2(0);
            time = 0;
            this.wind = wind;
            this.noise = noise;
        }

        void step() {
            import std.random;
            enum TIME_STEP = 0.02;
            vel += vec2(uniform(-noise, +noise), uniform(-noise, +noise));
            vel += wind * vec2(2,1) * time * time * (1 - time) * 6 * TIME_STEP * 0.02;
            vertex.position += vec3(vel, 0);
            time += TIME_STEP;

            if (time > 1) time = 1;
        }
    }

    class StartEffectMaterial : Material {
        mixin ConfigureMaterial!(q{{
            "VertexShaderAutoGen" : false
        }});

        private utexture tex;
        private ufloat fragWidth, fragHeight;
        private ufloat sizeInPixel;
        ufloat textAlpha;
        ufloat lineRate;
        float aspectRatio;

        this(string str) {
            mixin(autoAssignCode);
            super();
            auto texture = new StringTexture(FontLoader.load(FontPath("Kaiso-Next-B.otf"), 512), str);
            this.tex = texture;
            this.config.faceMode = FaceMode.FrontBack;
            this.config.renderGroupName = "transparent";
            this.config.depthTest = false;
            this.config.srcFactor = BlendFactor.SrcAlpha;
            this.config.dstFactor = BlendFactor.One;
            GlFunction.enable(Capability.ProgramPointSize);
            this.aspectRatio = texture.aspectRatio;
        }
    }
}
