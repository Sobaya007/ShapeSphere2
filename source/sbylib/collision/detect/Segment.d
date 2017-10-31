module sbylib.collision.detect.Segment;

import sbylib.math.Vector;
import std.algorithm;

struct Segment {
    vec3 s, e;
}

struct CollisionPoint {
    vec3 pos;
    float param;
    uint[2] idx;

    this(vec3 pos) {
        this.pos = pos;
    }

    this(vec3 pos, float param) {
        this.pos = pos;
        this.param = param;
    }
}

struct CollisionResult {
    CollisionPoint[6] nearest;
    uint npoints;
    vec3 normal;
    float distance;

    this(CollisionPoint point, vec3 n, float d) {
        this.nearest[0] = point;
        this.npoints = 1;
        this.normal = n;
        this.distance = d;
    }

    this(CollisionPoint point, vec3 v) {
        this.nearest[0] = point;
        this.npoints = 1;
        this.distance = v.length;
        this.normal = v.safeNormalize;
    }

    this(CollisionPoint p0, CollisionPoint p1, vec3 v) {
        this.nearest[0] = p0;
        this.nearest[1] = p1;
        this.distance = v.length;
        this.normal = v.safeNormalize;
    }

    void param(float p) @property {
        assert(npoints == 1);
        this.nearest[0].param = p;
    }

    void idx(uint idx) @property {
        foreach (i; 0..npoints) {
            this.nearest[i].idx[0] = idx;
        }
    }

    void idx(uint[2] idx) @property {
        foreach (i; 0..npoints) {
            this.nearest[i].idx = idx;
        }
    }
}

public static CollisionResult[2] testSegments(Segment s1, Segment s2) {
    vec3 v1 = normalize(s1.e - s1.s);
    vec3 v2 = normalize(s2.e - s1.s);
    float d1 = dot(s2.s - s1.s, v1);
    float d2 = dot(s2.s - s1.s, v2);
    float dv = dot(v1, v2);
    float denom = 1 - dv * dv;
    if (denom < 1e-4) {
        // parallel
        return testParallelSegments(s1, s2);
    }
    denom = 1 / denom;
    float t1 = (d1 - dv * d2) * denom;
    float t2 = (d1 * dv - d2) * denom;
    if (t1 < 0) {
        if (t2 < 0) {
            // point & point
            auto res = testPoints(s1.s, s2.s);
            res[0].param = 0;
            res[1].param = 0;
            return res;
        } else if (t2 > 1) {
            // point & point
            auto res = testPoints(s1.s, s2.e);
            res[0].param = 0;
            res[1].param = 1;
            return res;
        } else {
            // point & line
            auto res = testPointSegment(s1.s, s2);
            res[0].param = 0;
            return res;
        }
    } else if (t1 > 1) {
        if (t2 < 0) {
            // point & point
            auto res = testPoints(s1.e, s2.s);
            res[0].param = 1;
            res[1].param = 0;
            return res;
        } else if (t2 > 1) {
            // point & point
            auto res = testPoints(s1.e, s2.e);
            res[0].param = 1;
            res[1].param = 1;
            return res;
        } else {
            // point & line
            auto res = testPointSegment(s1.e, s2);
            res[0].param = 1;
            return res;
        }
    } else {
        if (t2 < 0) {
            // line & point
            auto res = testPointSegment(s2.s, s1);
            res[0].param = 0;
            return [res[1], res[0]];
        } else if (t2 > 1) {
            // line & point
            auto res = testPointSegment(s2.e, s1);
            res[0].param = 1;
            return [res[1], res[0]];
        } else {
            // line & line
            vec3 p1 = s1.s + t1 * v1;
            vec3 p2 = s2.s + t2 * v2;
            auto result1 = CollisionResult(CollisionPoint(p1, t1), p1 - p2);
            auto result2 = CollisionResult(CollisionPoint(p2, t2), p2 - p1);
            return [result1, result2];
        }
    }
}

public static CollisionResult[2] testParallelSegments(Segment s1, Segment s2) {
    vec3 v = normalize(s1.e - s1.s);
    auto startCoord1 = dot(v, s1.s);
    auto startCoord2 = dot(v, s2.s);
    auto endCoord1   = dot(v, s1.e);
    auto endCoord2   = dot(v, s2.e);
    if (startCoord1 > endCoord1) swap(startCoord1, endCoord1);
    if (startCoord2 > endCoord2) swap(startCoord2, endCoord2);
    auto commonStartCoord = max(startCoord1, startCoord2);
    auto commonEndCoord   = min(endCoord1, endCoord2);
    auto d1 = s1.s;
    d1 -= dot(d1, v) * v;
    auto d2 = s2.s;
    d2 -= dot(d2, v) * v;
    auto d = s1.s - s2.s;
    d -= dot(d, v) * v;
    auto l1 = length(s1.e - s1.s);
    auto l2 = length(s2.e - s2.s);
    auto result1 = CollisionResult(
            CollisionPoint(d1 + v * commonStartCoord, commonStartCoord / l1),
            CollisionPoint(d1 + v * commonEndCoord, commonEndCoord / l1),  d);
    auto result2 = CollisionResult(
            CollisionPoint(d2 + v * commonStartCoord, commonStartCoord / l2),
            CollisionPoint(d2 + v * commonEndCoord, commonEndCoord / l2), -d);
    return [result1, result2];
}

public static CollisionResult[2] testPointSegment(vec3 p, Segment s) {
    if (s.s == s.e) {
        auto res = testPoints(p, s.s);
        res[1].param = 0;
        return res;
    } else {
        auto v = s.e - s.s;
        vec3 vn = normalize(v);
        float t = dot(p - s.s, vn);
        t /= length(v);
        t = clamp(t, 0, 1);
        vec3 p1 = s.s + t * v;
        auto result1 = CollisionResult(CollisionPoint(p1, t), p1 - p);
        auto result2 = CollisionResult(CollisionPoint(p), p - p1);
        return [result1, result2];
    }
}

public static CollisionResult[2] testPoints(vec3 p0, vec3 p1) {
    auto result1 = CollisionResult(CollisionPoint(p0), p0 - p1);
    auto result2 = CollisionResult(CollisionPoint(p1), p1 - p0);
    return [result1, result2];
}
