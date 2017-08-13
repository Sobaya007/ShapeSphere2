module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
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
    Entity floors;
    private BaseSphere sphere;
    private ElasticSphere elasticSphere;
    private NeedleSphere needleSphere;
    private Key key;
    Camera camera;
    flim pushCount;
    CommandSpawner[] commandSpawners;

    this(Key key, Camera camera) {
        auto geom = Sphere.create(ElasticSphere.DEFAULT_RADIUS, ElasticSphere.RECURSION_LEVEL);
        auto mat = new Mat();
        mat.ambient = vec3(1);
        this.entity = new PlayerEntity(geom, mat);
        this.floors = new Entity();
        this.particleList = this.generateParticles(geom);
        this.pairList = this.generatePairs(geom, this.particleList);
        this.initParticles(this.particleList, this.pairList);
        this.elasticSphere = new ElasticSphere(this);
        this.needleSphere = new NeedleSphere(this);
        this.sphere = this.elasticSphere;
        this.key = key;
        this.camera = camera;
        this.pushCount = flim(0.0, 0.0, 1);
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
        this.sphere.move();
        this.updateGeometry();
    }

    void onDownPress() {
        this.sphere.onDownPress();
    }

    void onDownJustRelease() {
        this.sphere.onDownJustRelease();
    }

    void onNeedlePress() {
        if (this.sphere !is this.needleSphere) {
            this.sphere = this.needleSphere;
            this.needleSphere.initialize();
        }
        this.needleSphere.onNeedlePress();
    }

    void onNeedleRelease() {
        if (this.sphere != this.needleSphere) return;
        this.sphere.onNeedleRelease();
        if (this.needleSphere.hasFinished) {
            this.sphere = this.elasticSphere;
            this.elasticSphere.fromNeedle(this.needleSphere);
        }
    }

    void onLeftPress() {
        this.sphere.onLeftPress();
    }

    void onRightPress() {
        this.sphere.onRightPress();
    }

    void onForwardPress() {
        this.sphere.onForwardPress();
    }

    void onBackPress() {
        this.sphere.onBackPress();
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

    private void updateGeometry() {
        auto geom = this.entity.getMesh().geom;
        auto vs = geom.vertices;
        foreach (ref v; vs) {
            v.normal = vec3(0);
        }
        foreach (face; geom.faces) {
            auto normal = normalize(cross(
                    vs[face.indexList[2]].position - vs[face.indexList[0]].position,
                    vs[face.indexList[1]].position - vs[face.indexList[0]].position));
            vs[face.indexList[0]].normal += normal;
            vs[face.indexList[1]].normal += normal;
            vs[face.indexList[2]].normal += normal;
        }
        foreach (i,v; vs) {
            auto p = this.particleList[i];
            v.normal = safeNormalize(v.normal);
            v.position = (this.entity.obj.viewMatrix * vec4(p.position, 1)).xyz;
        }
        geom.updateBuffer();
    }
}
