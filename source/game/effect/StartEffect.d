module game.effect.StartEffect;

import game.Game;
import game.effect.Effect;
import sbylib;

class StartEffect : Effect {

    alias StartEffectEntity = TypedEntity!(TypedGeometry!([Attribute.Position, Attribute.UV], Prim.Point), StartEffectMaterial);
    StartEffectEntity entity;
    Fragment[] fragmentList;

    this() {
        const viewport = Game.getScene().viewport;
        const screenAspect = viewport.getWidth / viewport.getHeight;
        const FRAG_HEIGHT = 0.01;
        const FRAG_WIDTH = FRAG_HEIGHT * Core().getWindow.getHeight / Core().getWindow.getWidth;
        auto mat = new StartEffectMaterial();
        const H = 0.3;
        const W = H * mat.aspectRatio;
        auto X_DIV = W/FRAG_WIDTH;
        auto Y_DIV = H/FRAG_HEIGHT;
        mat.fragWidth = FRAG_WIDTH/W;
        mat.fragHeight = FRAG_HEIGHT/H;
        mat.sizeInPixel = FRAG_HEIGHT * Core().getWindow.getHeight * 0.5;

        VertexT[] vertices;
        foreach (i; 0..X_DIV) {
            auto u1 = i / X_DIV;
            auto x1 = (u1-0.5)*W + FRAG_WIDTH/2;
            foreach (j; 0..Y_DIV) {
                auto v1 = j / Y_DIV;
                auto y1 = (v1-0.5)*H + FRAG_HEIGHT/2;
                auto vertex = new VertexT(vec3(x1,y1,0), vec2(u1,v1));
                vertices ~= vertex;
                fragmentList ~= Fragment(vertex);
            }
        }
        auto geom = new TypedGeometry!([Attribute.Position, Attribute.UV], Prim.Point)(vertices);
        this.entity = makeEntity(geom, mat);
        Game.getWorld2D().add(entity);

        AnimationManager().startAnimation(sequence(
            multi(
                animation((float alpha) => mat.textAlpha = alpha, setting(0.0f, 1.0f, 120.frame, &Ease.linear)),
                animation((float lineRate) => mat.lineRate = lineRate, setting(0.0f, 1.0f, 120.frame, &Ease.linear)),
            ),
            wait(30.frame),
            animation(&po)
        ));
    }

    override void step() {
    }

    void po(void delegate() kill) {
        foreach (ref frag; fragmentList) {
            frag.step();
        }
        entity.mesh.geom.updateBuffer();
        entity.mat.textAlpha -= 0.01;
        if (entity.mat.textAlpha.value < 0) kill();
    }

    override bool done() {
        return entity.mat.textAlpha.value < 0;
    }

    private struct Fragment {
        VertexT vertex;
        vec2 vel;
        float time;

        this(VertexT vertex) {
            this.vertex = vertex;
            vel = vec2(0);
            time = 0;
        }

        void step() {
            import std.random;
            enum NOISE = 0.001;
            enum TIME_STEP = 0.02;
            vel += vec2(uniform(-NOISE, +NOISE), uniform(-NOISE, +NOISE));
            vel += vec2(2,1) * time * time * (1 - time) * 6 * TIME_STEP * 0.02;
            vertex.position += vec3(vel, 0);
            time += TIME_STEP;
            
            if (time > 1) time = 1;
        }
    }

    class StartEffectMaterial : Material {
        mixin declare!(false);

        private utexture texture;
        private ufloat fragWidth, fragHeight;
        private ufloat sizeInPixel;
        ufloat textAlpha;
        ufloat lineRate;
        float aspectRatio;

        this() {
            mixin(autoAssignCode);
            super();
            auto texture = new StringTexture(FontLoader.load(FontPath("meiryo.ttc"), 512), "山田太郎はホモ");
            this.texture = texture;
            this.config.faceMode = FaceMode.FrontBack;
            this.config.renderGroupName = "transparent";
            this.config.depthTest = false;
            //this.config.srcFactor = BlendFactor.SrcAlpha;
            //this.config.dstFactor = BlendFactor.One;
            GlFunction.enable(Capability.ProgramPointSize);
            this.aspectRatio = texture.aspectRatio;
            //this.aspectRatio = img.getWidth / img.getHeight;
        }
    }
}
