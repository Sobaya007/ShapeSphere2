module sbylib.animation.Ease;

alias EaseFunc = float function(float);

class Ease {
    enum identity = (float t) => t;
    enum quad = (float t) => t * t;
}
