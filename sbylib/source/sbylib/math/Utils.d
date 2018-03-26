module sbylib.math.Utils;

import std.math;
import sbylib.math;

U toRad(U)(U angle) {
    return angle * PI / 180;
}

U toDeg(U)(U angle) {
    return angle * 180 / PI;
}

float sup(float t,float limit, float t0 = 0, float speed = 1) {
    return limit + speed / (t - speed / (limit - t0));
}
