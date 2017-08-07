module game.player.Player;

import game.command;
import game.player.ElasticSphere;
import game.player.Particle;
import game.player.PlayerMaterial;
import game.player.Pair;
import sbylib;
import std.algorithm, std.array;
import std.math;

class Player {

    alias Mat = ConditionalMaterial!(PlayerMaterial, LambertMaterial);
    alias PlayerEntity = EntityTemp!(GeometryN, Mat);

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    Particle[] particleList;
    Pair[] pairList;
    PlayerEntity entity;
    Entity[] floors;
    private ElasticSphere esphere;
    private Key key;
    private Camera camera;
    flim pushCount;
    private vec3 force;
    CommandSpawner[] commandSpawners;

    this(Key key, Camera camera) {
        auto geom = Sphere.create(ElasticSphere.DEFAULT_RADIUS, ElasticSphere.RECURSION_LEVEL);
        auto mat = new Mat();
        mat.ambient = vec3(1);
        this.entity = new PlayerEntity(geom, mat);
        this.particleList = this.generateParticles(geom);
        this.pairList = this.generatePairs(geom, this.particleList);
        this.initParticles(this.particleList, this.pairList);
        this.esphere = new ElasticSphere(this);
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
        this.esphere.move();
        this.entity.getMesh().geom.updateBuffer();
        this.force.y = 0;
        if (this.force.length > 0) this.force = normalize(this.force) * SIDE_PUSH_FORCE;
        foreach (p; this.particleList) {
            p.force = this.force;
        }
        this.force = vec3(0);
    }

    void onDownPress() {
        this.pushCount += 0.1;
        vec3 g = this.entity.obj.pos;
        auto lower = this.esphere.calcLower();
        auto upper = this.esphere.calcUpper();
        foreach (p; this.particleList) {
            //下向きの力
            auto len = (p.position - g).xz.length;
            auto t = (p.position.y - lower) / (upper - lower);
            float power = DOWN_PUSH_FORCE / pow(len + 0.6, 2.5);
            power = min(DOWN_PUSH_FORE_MIN, power);
            power *= t;
            p.force.y -= power * this.pushCount;
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

    private Particle[] generateParticles(const GeometryN geom) const {
        auto particleList = geom.vertices.map!(v => new Particle(v.position)).array;
        particleList.each!( p => p.position += vec3(0,20,0));
        return particleList;
    }

    private Pair[] generatePairs(const GeometryN geom, Particle[] particles) const {
        //隣を発見
        uint[2][] pairIndex;
        uint[2] makePair(uint a,uint b) {
            return a < b ? [a,b] : [b,a];
        }
        foreach (face; geom.faces) {
            auto idx0 = face.indexList[0];
            auto idx1 = face.indexList[1];
            auto idx2 = face.indexList[2];

            if (pairIndex.canFind(makePair(idx0,idx1)) == false) pairIndex ~= makePair(idx0,idx1);
            if (pairIndex.canFind(makePair(idx1,idx2)) == false) pairIndex ~= makePair(idx1,idx2);
            if (pairIndex.canFind(makePair(idx2,idx0)) == false) pairIndex ~= makePair(idx2,idx0);
        }
        return pairIndex.map!(pair => Pair(particles[pair[0]], particles[pair[1]])).array;
    }

    private void initParticles(Particle[] particles, Pair[] pairs) const {
        foreach(pair; pairs) {
            pair.p0.next ~= pair.p1;
            pair.p1.next ~= pair.p0;
        }
        foreach (p; particles) {
            p.isStinger = p.next.all!(a => a.isStinger == false);
        }
    }
}
