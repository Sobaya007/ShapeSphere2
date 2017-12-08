module game.camera.PlayerChaseCamera;

import sbylib;
import game.player.Player;

class PlayerChaseCamera {

    private interface Step {
        Step step();
        void turn(vec2);
    }

    private static float TURN_SPEED = 2;

    Camera camera;  alias camera this;
    private Player player;
    private vec3 vel;
    private Maybe!vec3 arrival;
    private ConstTemp!float defaultLength, k, c;
    private NormalStep normalStep;
    private ResetStep resetStep;
    private LookOverStep lookOverStep;
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
        this.lookOverStep = new LookOverStep;
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

        override void turn(vec2 value) {
            auto v = this.player.getCameraTarget() - this.camera.getObj().pos;
            auto arrival = normalize(cross(vec3(0,1,0),v)) * TURN_SPEED * value.x;
            auto dif = arrival - vel;
            vel += dif * 0.1;
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

        Step init() {
            this.dir = player.getLastDirection;
            this.count = 15;
            return this;
        }

        override Step step() {
            auto r = (player.getCameraTarget() - camera.pos).xz.length;
            auto arrival = player.getCameraTarget() - r * dir;
            auto t = player.getCameraTarget;
            vel = (arrival - camera.pos) * 0.1;
            vel.y = 0;
            camera.pos += vel;
            auto ay = t.y + 3;
            camera.pos.y = (camera.pos.y - ay) * 0.9 + ay;
            camera.lookAt(t);
            if (this.count --> 0) {
                return resetStep;
            }
            return normalStep;
        }

        override void turn(vec2 v) {
        }
    }

    private class LookOverStep : Step {

        enum RADIUS = 20;
        private vec3 targetArrival;
        private vec3 target;
        private vec3 center;
        private vec3 dir;

        Step init(vec3 dir) {
            this.dir = dir;
            this.center = player.getCameraTarget();
            this.target = this.center;
            this.targetArrival = this.center + dir * RADIUS;
            return this;
        }

        override Step step() {
            camera.pos += (player.getCameraTarget() - this.dir * 0.01 - camera.pos) * 0.1;
            this.target += (this.targetArrival - this.target) * 0.05;
            camera.lookAt(this.target);
            return lookOverStep;
        }

        override void turn(vec2 v) {
            auto xvec = normalize(cross(this.dir, vec3(0,1,0)));
            auto yvec = normalize(cross(this.dir, xvec));
            this.dir += mat3x2(xvec, yvec) * v * 0.03;
            this.dir = normalize(this.dir);
            this.targetArrival = this.center + this.dir * RADIUS;
        }
    }

    void turn(vec2 value) {
        this.stepImpl.turn(value);
    }

    void reset() {
        this.stepImpl = resetStep.init();
    }

    void lookOver(vec3 dir) {
        this.stepImpl = this.lookOverStep;
        this.lookOverStep.init(dir);
    }

    void stopLookOver() {
        if (this.stepImpl !is this.lookOverStep) return;
        this.stepImpl = this.normalStep;
    }

    bool isLooking() {
        return this.stepImpl is this.lookOverStep;
    }
}
