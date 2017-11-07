module sbylib.animation.Ease;

alias EaseFunc = float function(float);

class Ease {
    enum linear = (float t) => t;
    enum quad = (float t) => t * t;
    enum easeInOut = (float t) => t * t * (3 - 2 * t);
}
