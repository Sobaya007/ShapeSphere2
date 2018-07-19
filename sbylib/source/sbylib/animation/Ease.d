module sbylib.animation.Ease;

alias EaseFunc = float function(float);

struct Ease {
static:
    auto linear(float t) { return t;}
    auto quad(float t) { return t * t;}
    auto inOut(float t) { return t * t * (3 - 2 * t);}

    EaseFunc Linear = &linear;
    EaseFunc Quad = &quad;
    EaseFunc InOut = &inOut;
}
