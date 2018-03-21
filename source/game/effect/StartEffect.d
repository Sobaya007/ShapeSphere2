module game.effect.StartEffect;

import game.Game;
import game.effect.Effect;
import sbylib;

class StartEffect : Effect {

    Entity entity;
    Fragment[] fragmentList;

    this() {
        this.entity = new Entity;
        enum W = 2;
        enum H = 1;
        enum FRAG_SIZE = 0.05;
        enum X_DIV = W/FRAG_SIZE;
        enum Y_DIV = H/FRAG_SIZE;
        auto mat = new TextureMaterial(ImageLoader.load(ImagePath("d.png")));
        mat.config.faceMode = FaceMode.FrontBack;
        foreach (i; 0..X_DIV) {
            auto u1 = i / X_DIV;
            auto x1 = (u1-0.5)*W;
            auto u2 = (i+1) / X_DIV;
            auto x2 = (u2-0.5)*W;
            foreach (j; 0..Y_DIV) {
                auto v1 = j / Y_DIV;
                auto y1 = (v1-0.5)*H;
                auto v2 = (j+1) / Y_DIV;
                auto y2 = (v2-0.5)*H;
                auto geom = new GeometryTemp!([Attribute.Position, Attribute.UV], Prim.TriangleFan)([
                    new VertexT(vec3(-FRAG_SIZE/2,-FRAG_SIZE/2,0), vec2(u1,v1)),
                    new VertexT(vec3(+FRAG_SIZE/2,-FRAG_SIZE/2,0), vec2(u2,v1)),
                    new VertexT(vec3(+FRAG_SIZE/2,+FRAG_SIZE/2,0), vec2(u2,v2)),
                    new VertexT(vec3(-FRAG_SIZE/2,+FRAG_SIZE/2,0), vec2(u1,v2)),
                ]);
                auto e = makeEntity(geom, mat);
                e.pos = vec3((x1+x2)/2, (y1+y2)/2, 0);
                entity.addChild(e);
                fragmentList ~= Fragment(e);
            }
        }
        Game.getWorld2D().add(entity);
    }

    override void step() {
        foreach (ref frag; fragmentList) {
            frag.step();
        }
    }

    override bool done() {
        return false;
    }

    private struct Fragment {
        Entity entity;
        vec2 vel;
        float time;

        this(Entity e) {
            this.entity = e;
            vel = vec2(0);
            time = 0;
        }

        void step() {
            import std.random;
            enum NOISE = 0.001;
            enum TIME_STEP = 0.02;
            vel += vec2(uniform(-NOISE, +NOISE), uniform(-NOISE, +NOISE));
            vel += vec2(2,1) * time * time * (1 - time) * 6 * TIME_STEP * 0.02;
            entity.pos += vec3(vel, 0);
            time += TIME_STEP;
            
            if (time > 1) time = 1;
        }
    }
}
