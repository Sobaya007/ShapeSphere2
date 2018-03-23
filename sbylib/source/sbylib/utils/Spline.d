module sbylib.utils.Spline;

import sbylib.math.Vector;
import sbylib.math.Matrix;

class Spline(uint Dim) {

    alias Vec = Vector!(float, Dim);

    private struct Point {
        Vec p, v;
    }

    private Point[] pointList;
    private float[] timeList;

    this(Vec[] points, float speed) in {
        assert(points.length >= 2);
    } do {
        foreach (i, p; points) {
            if (i == 0) pointList ~= Point(p, speed * normalize(points[1] - p));
            else if (i == points.length-1) {
                pointList ~= Point(p, speed * normalize(p - points[$-2]));
            } else {
                pointList ~= Point(p, 10 * speed * normalize(normalize(points[i+1] - p) - normalize(points[i-1] - p)));
            }
        }
        foreach (i; 0..points.length-1) {
            auto length = length(points[i+1] - points[i]); // that's
            timeList ~= length / speed;
        }
    }

    Vec getPoint(float time) {
        if (time < 0) return pointList[0].p;
        foreach (i, period; timeList) {
            if (time < period) {
                return getPoint(time/period, pointList[i], pointList[i+1]);
            }
            time -= period;
        }
        return pointList[$-1].p;
    }

    Vec getPoint(float t, Point a, Point b) {
        auto T = Matrix!(float,1,4)(t^^3, t^^2, t, 1);
        enum H = mat4(
                2, -2, 1, 1,
                -3, 3, -2, -1,
                0, 0, 1, 0,
                1, 0, 0, 0
            );
        auto G = Vector!(Vec, 4)(a.p, b.p, a.v, b.v);
        return (T * H * G)[0];
    }

    Vec getVelocity(float time) {
        if (time < 0) return Vec(0);
        foreach (i, period; timeList) {
            if (time < period) {
                return getVelocity(time/period, pointList[i], pointList[i+1]);
            }
            time -= period;
        }
        return Vec(0);
    }

    Vec getVelocity(float t, Point a, Point b) {
        enum Delta = 0.001;
        return (getPoint(t+Delta, a, b) - getPoint(t, a, b)) / Delta;
    }
}
