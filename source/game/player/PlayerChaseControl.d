module game.player.PlayerChaseControl;

import sbylib;
import game.player.Player;

class PlayerChaseControl {

    private interface Step {
        Step step();
    }

    private static float TURN_SPEED = 2;

    private Camera camera;
    private Player player;
    private vec3 vel;
    private Maybe!vec3 arrival;
    private ConstTemp!float defaultLength, k, c;
    private NormalStep normalStep;
    private ResetStep resetStep;
    private Step stepImpl;

    this(Camera camera, Player player) {
        this.camera = camera;
        this.player = player;
        this.defaultLength = ConstantManager.get!float("defaultLength");
        this.k = ConstantManager.get!float("k");
        this.c = ConstantManager.get!float("c");
        this.vel = vec3(0);
        this.normalStep = new NormalStep(player, camera);
        this.resetStep = new ResetStep(player, camera);
        this.stepImpl = this.normalStep;
    }

    void step() {
        this.stepImpl = this.stepImpl.step();
    }

    private class NormalStep : Step {

        private Player player;
        private Camera camera;

        this(Player player, Camera camera) {
            this.player = player;
            this.camera = camera;
        }

        override Step step() {
            auto t = player.getCameraTarget();
            auto v = camera.getObj().pos - t;
            auto dp = v.length - defaultLength;
            auto dy = v.y;
            v = normalize(v);
            vel -= (k * dp + c * dot(vel, v)) * v;
            vel *= 1 - c;
            auto cobj = camera.getObj();
            cobj.pos += vel;
            auto ay = t.y + 3;
            cobj.pos.y = (cobj.pos.y - ay) * 0.9 + ay;
            cobj.lookAt(t);
            return normalStep;
        }
    }

    private class ResetStep : Step {
        
        private Player player;
        private Camera camera;
        private vec3 dir;
        private int count;

        this(Player player, Camera camera) {
            this.player = player;
            this.camera = camera;
        }

        Step init(vec3 dir) {
            this.dir = dir;
            this.count = 15;
            return this;
        }

        override Step step() {
            auto r = (player.getCameraTarget() - camera.pos).xz.length;
            auto arrival = player.getCameraTarget() - r * dir;
            auto t = player.getCameraTarget;
            vel = (arrival - camera.pos) * 0.1;
            camera.pos += vel;
            auto ay = t.y + 3;
            camera.pos.y = (camera.pos.y - ay) * 0.9 + ay;
            camera.lookAt(t);
            if (this.count --> 0) {
                return resetStep;
            }
            return normalStep;
        }
    }

    void turn(float value) {
        if (this.stepImpl !is this.normalStep) return;
        auto v = this.player.getCameraTarget() - this.camera.getObj().pos;
        auto arrival = normalize(cross(vec3(0,1,0),v)) * TURN_SPEED * value;
        auto dif = arrival - vel;
        vel += dif * 0.1;
    }

    void reset() {
        auto mdir = this.player.getLastDirection();
        if (mdir.isNone) return;
        auto dir = mdir.get;
        this.stepImpl = resetStep.init(dir);
    }
}
