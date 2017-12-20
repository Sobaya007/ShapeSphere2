module game.camera.CameraController;

import sbylib;
import game.player.Player;
import std.meta, std.algorithm, std.array;
import game.camera.behavior;

class CameraController {

    alias BehaviorTypes = AliasSeq!(ChaseBehavior, ResetBehavior, LookOverBehavior, FocusBehavior);

    package interface Behavior {
        void step();
        void turn(vec2);

        mixin template BehaviorPack() {
            private CameraController controller;

            this(CameraController controller) {
                this.controller = controller;
            }

            alias controller this;
        }
    }

    package static float TURN_SPEED = 2;

    Camera camera;
    alias camera this;
    package Player player;
    package ConstTemp!float defaultLength, k, c;
    package vec3 vel;
    package vec3 target;
    private Maybe!vec3 arrival;
    private Behavior[] behaviors;
    private Behavior behavior;

    this(Camera camera, Player player) {
        this.camera = camera;
        this.player = player;
        this.defaultLength = ConstantManager.get!float("defaultLength");
        this.k = ConstantManager.get!float("k");
        this.c = ConstantManager.get!float("c");
        this.vel = vec3(0);
        static foreach (Type; BehaviorTypes) {
            this.behaviors ~= new Type(this);
        }
    }

    void initialize() {
        auto chase = this.transit!(ChaseBehavior);
        chase.initialize();
    }

    package T transit(T)() out (res) {
        assert(res !is null);
    } body {
        return cast(T)(this.behavior = this.behaviors.find!(b => b.instanceof!T).front);
    }

    void step() {
        this.behavior.step();
    }

    void turn(vec2 value) {
        this.behavior.turn(value);
    }

    void chase() {
        transit!(ChaseBehavior);
        // don't call initialize
    }

    void reset() {
        auto reset = transit!(ResetBehavior);
        reset.initialize();
    }

    void lookOver(vec3 dir) {
        auto lookOver = transit!(LookOverBehavior);
        lookOver.initialize(dir);
    }

    void focus(Object3D obj) {
        auto focus = transit!(FocusBehavior);
        auto v = obj.pos - camera.pos;
        v.y = 0;
        v = normalize(v);
        v.y = -1;
        v = normalize(v);
        focus.initialize(obj, v);
    }

    void stopLookOver() {
        if (!isLooking) return;
        transit!ChaseBehavior();
    }

    bool isLooking() {
        return this.behavior.instanceof!LookOverBehavior;
    }
}
