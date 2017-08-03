module game.player.Player;

import game.command;
import game.player.ElasticSphere;
import sbylib;
import std.algorithm;
import std.math;

class Player {

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    ElasticSphere esphere;
    private Key key;
    private Camera camera;
    flim pushCount;
    private vec3 force;
    CommandSpawner[] commandSpawners;

    this(Key key, Camera camera) {
        this.esphere = new ElasticSphere();
        this.key = key;
        this.camera = camera;
        this.pushCount = flim(0.0, 0.0, 1);
        this.force = vec3(0);
        this.commandSpawners = [
            new CommandSpawner(() => key.isPressed(KeyButton.Space), new Command(&this.onDownPress)),
            new CommandSpawner(() => key.justReleased(KeyButton.Space), new Command(&this.onDownJustRelease)),
            new CommandSpawner(() => key.isPressed(KeyButton.KeyX), new Command(&this.onNeedlePress)),
            new CommandSpawner(() => key.isReleased(KeyButton.KeyX), new Command(&this.onNeedleRelease)),
            new CommandSpawner(() => key.isPressed(KeyButton.Left), new Command(&this.onLeftPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Right), new Command(&this.onRightPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Up), new Command(&this.onForwardPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Down), new Command(&this.onBackPress))];
    }

    void step() {
        this.force.y = 0;
        if (this.force.length > 0) this.force = normalize(this.force) * SIDE_PUSH_FORCE;
        foreach (p; this.esphere.particleList) {
            p.force += this.force;
        }
        this.force = vec3(0);
        foreach (p; this.esphere.particleList) {
            p.extForce = vec3(0,0,0);
        }
    }

    void onDownPress() {
        this.pushCount += 0.1;
        vec3 g = this.esphere.entity.obj.pos;
        foreach (p; this.esphere.particleList) {
            //下向きの力
            float len = length(p.p.xz - g.xz);
            float powerMax = min(DOWN_PUSH_FORE_MIN, DOWN_PUSH_FORCE / pow(len + 0.6, 2.5)) * (p.p.y - this.esphere.lowerY) / (this.esphere.upperY - this.esphere.lowerY);
            p.extForce.y -= powerMax * this.pushCount;
        }
    }

    void onDownJustRelease() {
        this.pushCount = 0;
    }

    void onNeedlePress() {
        this.esphere.needleCount += 0.1;
    }

    void onNeedleRelease() {
        this.esphere.needleCount -= 0.3;
    }

    void onLeftPress() {
        this.force -= this.camera.rot.column[0].xyz;
    }

    void onRightPress() {
        this.force += this.camera.rot.column[0].xyz;
    }

    void onForwardPress() {
        this.force -= this.camera.rot.column[2].xyz;
    }

    void onBackPress() {
        this.force += this.camera.rot.column[2].xyz;
    }
}
