module sbylib.animation.Utils;

import sbylib.animation.Animation;
import sbylib.animation.AnimationManager;
import sbylib.animation.Ease;
import sbylib.entity.Entity;
import sbylib.math.Angle;
import sbylib.math.Vector;
import sbylib.utils.Unit;

class AnimationBuilder {
    alias Builder = IAnimationWithPeriod delegate(Entity);
    private Builder builder;

    this(Builder builder) {
        this.builder = builder;
    }

    IAnimationWithPeriod build(Entity e) {
        return builder(e);
    }
}

class AnimationProcedureBuilder {

    private AnimationProcedure delegate() call;
    private void delegate() onFinish;

    this(Entity e, AnimationBuilder[] builders...) {
        import std.algorithm : map;

        AnimationProcedure call(size_t i) {
            auto a = AnimationManager().startAnimation(builders[i].build(e));
            if (i+1 < builders.length) {
                a.onFinish({
                    call(i+1);
                });
            } else {
                a.onFinish({if (onFinish) onFinish();});
            }
            return a;
        }
        this.call = { return call(0); };
        this.build();
    }

    AnimationProcedure build() {
        return call();
    }

    typeof(this) repeat() {
        this.onFinish = {this.build();};
        return this;
    }
}

auto animate(Entity entity, AnimationBuilder[] anims...) {

    return new AnimationProcedureBuilder(entity, anims);
}

AnimationBuilder moveTo(vec3 arrival, Frame period, EaseFunc ease) {
    return new AnimationBuilder((Entity e) {
        return animation((vec3 pos) { e.pos = pos; }, setting(e.pos, arrival, period, ease));
    });
}

AnimationBuilder rot(vec3 axis, Angle arrival, Frame period, EaseFunc ease) {
    import sbylib.math.Matrix;
    return new AnimationBuilder((Entity e) {
        mat3 dst = e.rot;
        return animation((Angle r) { e.rot = dst * mat3.axisAngle(axis, r); }, setting(0.rad, arrival, period, ease));
    });
}
