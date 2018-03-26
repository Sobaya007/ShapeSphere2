module sbylib.animation.Ease;

alias EaseFunc = float function(float);

class Ease {
    static auto linear(float t) {
        return t;
    }
    static auto quad(float t) {
        return t * t;
    }
    static auto easeInOut(float t) {
        return t * t * (3 - 2 * t);
    }
}
