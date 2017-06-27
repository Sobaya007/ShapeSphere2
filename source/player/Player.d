module player.Player;

import player.ElasticSphere;
import sbylib;
import std.algorithm;
import std.math;

class Player {

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;

    ElasticSphere esphere;
    private Window window;
    private Camera camera;
    flim pushCount;

    this(Window window, Camera camera) {
        this.esphere = new ElasticSphere();
        this.window = window;
        this.camera = camera;
        this.pushCount = flim(0.0, 0.0, 1);
    }

    void step() {
        vec3 g = this.esphere.mesh.obj.pos;
        //キー入力で動かす
        foreach (p; this.esphere.particleList) {
            p.extForce = vec3(0,0,0);
        }
        if (this.window.getKey(KeyButton.Space)) {
            this.pushCount += 0.1;
            foreach (p; this.esphere.particleList) {
                //下向きの力
                float len = length(p.p.xz - g.xz);
                float powerMax = min(DOWN_PUSH_FORE_MIN, DOWN_PUSH_FORCE / pow(len + 0.6, 2.5)) * (p.p.y - this.esphere.lowerY) / (this.esphere.upperY - this.esphere.lowerY);
                p.extForce.y -= powerMax * this.pushCount;
            }
        } else {
            this.pushCount = 0;
        }
        {
            vec3 f = vec3(0,0,0);
            if (this.window.getKey(KeyButton.Left)) {
                f -= this.camera.getObj().rot.get().column[0].xyz;
            }
            if (this.window.getKey(KeyButton.Right)) {
                f += this.camera.getObj().rot.get().column[0].xyz;
            }
            if (this.window.getKey(KeyButton.Up)) {
                f -= this.camera.getObj().rot.get().column[2].xyz;
            }
            if (this.window.getKey(KeyButton.Down)) {
                f += this.camera.getObj().rot.get().column[2].xyz;
            }
            f.y = 0;
            if (f.length > 0) f = normalize(f) * SIDE_PUSH_FORCE;
            foreach (p; this.esphere.particleList) {
                p.force += f;
            }
        }
        if (this.window.getKey(KeyButton.KeyX)) {
            this.esphere.needleCount += 0.1;
        } else {
            this.esphere.needleCount -= 0.3;
        }
    }
}
