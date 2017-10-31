module sbylib.collision.detect.SegmentPolygon;

import std.algorithm;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.collision.geometry.CollisionPolygon;
import sbylib.collision.detect.Segment;
import sbylib.utils.Maybe;

struct Polygon {
    vec3[3] positions;

    this(vec3[3] positions...) {
        this.positions = positions;
    }

    vec3 calcNormal() {
        return normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
    }
}

struct PositionInPolygon {
    PolygonRegion region;
    uint idx;            // if region is Point or Edge, this is index of it.
}

enum PolygonRegion {
    Point, Edge, Face
}

public static CollisionResult[2] testSegmentPolygon(Segment s, Polygon polygon) {
    if (s.s == s.e) {
        // segment degenerated.
        auto res = testPointPolygon(s.s, polygon);
        res[0].param = 0;
        return res;
    } else {
        vec3 v = s.e - s.s;
        vec3 normal = polygon.calcNormal;
        float denom = dot(v, normal);
        if (denom != 0) {
            // not parallel
            float t1 = dot(polygon.positions[0] - s.s, normal) / denom;
            // point & polygon
            t1 = clamp(t1, 0, 1); // you dont pay attention to whether segment penetrates polygon.
            vec3 p = s.s + t1 * v; //segment (will) penetrates face here.
            auto r = hit(p, polygon);
            final switch (r.region) {
                case PolygonRegion.Face:
                    // p is above the polygon.
                    auto result1 = CollisionResult(CollisionPoint(p, t1), vec3(0));
                    auto result2 = CollisionResult(CollisionPoint(p), vec3(0));
                    return [result1, result2];
                case PolygonRegion.Edge:
                    // p is outside of the polygon, and side of the edge consisted from p[idx] p[idx+1].
                    auto res = testSegments(s, Segment(polygon.positions[r.idx], polygon.positions[(r.idx+1)%3]));
                    res[1].idx = [r.idx, (r.idx+1)%3];
                    return res;
                case PolygonRegion.Point:
                    // p is outside of the polygon, and side of the p[idx].
                    auto res = testPointSegment(polygon.positions[r.idx], s);
                    res[0].idx = r.idx;
                    return [res[1], res[0]];
            }
        } else {
            // parallel
            // you may clip the segment.
            alias mat2x3 = Matrix!(float, 2, 3);
            auto base0 = polygon.positions[1] - polygon.positions[0];
            auto base1 = polygon.positions[2] - polygon.positions[1];
            auto trans2d = mat2x3(base0.x, base0.y, base0.z, base1.x, base1.y, base1.z);
            auto m = mat3(polygon.positions[0], polygon.positions[1], polygon.positions[2]);
            auto m2d = trans2d * m;
            auto s2d = trans2d * s.s;
            auto v2d = trans2d * v;
            auto v2dp = vec2(v2d.y, -v2d.x);
            auto C = dot(s2d, v2dp);
            auto M = mat2x3.transpose(m2d) * v2dp;
            auto lower0 = (C - M.y) / (M.z - M.y);
            auto upper0 = (C - M.x) / (M.z - M.y);
            if (lower0 > upper0) swap(lower0, upper0);
            auto lower1 = (C - M.x) / (M.z - M.x);
            auto upper1 = (C - M.y) / (M.z - M.x);
            if (lower1 > upper1) swap(lower1, upper1);
            auto lower = max(0, max(lower0, lower1));
            auto upper = min(1, min(upper0, upper1));

            if (lower > upper) {
                // segment is completely out of the polygon's sky.
                foreach (i; 0..3) {
                    auto cr = cross(polygon.positions[(i+1)%3] - polygon.positions[i], v);
                    if (cr == vec3(0)) {
                        // v is parallel to edge.
                        if (length(polygon.positions[(i+2)%3] - s.s) < length(polygon.positions[i] - s.s)) {
                            // near to point.
                            auto res = testPointSegment(polygon.positions[(i+2)%3], s);
                            res[0].idx = (i+2)%3;
                            return [res[1], res[0]];
                        } else {
                            // near to edge.
                            auto res = testParallelSegments(s, Segment(polygon.positions[i], polygon.positions[(i+1)%3]));
                            res[1].idx = [i, (i+1)%3];
                            return res;
                        }
                    }
                }
                // v is not parallel to any edge.
                CollisionResult[2] nearestResult;
                nearestResult[0].distance = 114514;
                foreach (i; 0..3) {
                    auto res = testSegments(s, Segment(polygon.positions[i], polygon.positions[(i+1)%3]));
                    if (res[0].distance < nearestResult[0].distance) {
                        nearestResult = res;
                        nearestResult[1].idx = [i, (i+1)%3];
                    }
                }
                assert(nearestResult[0].distance != 114514);
                return nearestResult;
            } else {
                // segment can be clipped.
                auto start = m * vec3(
                        (M.y - C) / (M.y - M.x) - (M.y - M.z) / (M.y - M.x) * lower,
                        (C - M.x) / (M.y - M.x) - (M.z - M.x) / (M.y - M.x) * lower,
                        lower);
                auto end = m * vec3(
                        (M.y - C) / (M.y - M.x) - (M.y - M.z) / (M.y - M.x) * upper,
                        (C - M.x) / (M.y - M.x) - (M.z - M.x) / (M.y - M.x) * upper,
                        upper);
                vec3 n = polygon.calcNormal;
                auto d = dot(n, start - polygon.positions[0]);
                auto d2 = n * d;
                auto result1 = CollisionResult(CollisionPoint(start), CollisionPoint(end), d2);
                auto result2 = CollisionResult(CollisionPoint(start-n*d), CollisionPoint(end-n*d), -d2);
                return [result1, result2];
            }
        }
    }
}

public static CollisionResult[2] testPointPolygon(vec3 p, Polygon polygon) {
    auto r = hit(p, polygon);
    final switch (r.region) {
        case PolygonRegion.Face:
            // p is above the polygon.
            vec3 n = polygon.calcNormal;
            float d = dot(n, p - polygon.positions[0]);
            vec3 v = n * d;
            vec3 foot = p - v;
            auto result1 = CollisionResult(CollisionPoint(foot),  v);
            auto result2 = CollisionResult(CollisionPoint(foot), -v);
            return [result1, result2];
        case PolygonRegion.Edge:
            // p is outside of the polygon, and side of the edge consisted from p[idx] p[idx+1].
            auto res = testPointSegment(p, Segment(polygon.positions[r.idx], polygon.positions[(r.idx+1)%3]));
            res[1].idx = [r.idx, (r.idx+1)%3];
            return res;
        case PolygonRegion.Point:
            // p is outside of the polygon, and side of the p[idx].
            auto res = testPoints(p, polygon.positions[r.idx]);
            res[1].idx = r.idx;
            return res;
    }
}

private PositionInPolygon hit(vec3 p, Polygon polygon) {
    auto normal = polygon.calcNormal;
    auto s0 = dot(normal, cross(polygon.positions[1] - polygon.positions[0], polygon.positions[0] - p));
    auto s1 = dot(normal, cross(polygon.positions[2] - polygon.positions[1], polygon.positions[1] - p));
    auto s2 = dot(normal, cross(polygon.positions[0] - polygon.positions[2], polygon.positions[2] - p));
    return hit(s0, s1, s2);
}

// returns the index of a number that has sign against others.
private PositionInPolygon hit(float a, float b, float c) {
    if (a > 0) {
        if (b > 0) {
            if (c > 0) {
                return PositionInPolygon(PolygonRegion.Face, -1);
            } else {
                return PositionInPolygon(PolygonRegion.Edge, 2);
            }
        } else {
            if (c > 0) {
                return PositionInPolygon(PolygonRegion.Edge, 1);
            } else {
                return PositionInPolygon(PolygonRegion.Point, 2);
            }
        }
    } else {
        if (b > 0) {
            if (c > 0) {
                return PositionInPolygon(PolygonRegion.Edge, 0);
            } else {
                return PositionInPolygon(PolygonRegion.Point, 0);
            }
        } else {
            if (c > 0) {
                return PositionInPolygon(PolygonRegion.Point, 1);
            } else {
                return PositionInPolygon(PolygonRegion.Face, -1);
            }
        }
    }
}

unittest {
    Polygon polygon = Polygon(vec3(20,0,-20), vec3(20,0,60), vec3(-20,0,-60));
    vec3 v = vec3(1,1,-1);
    Segment segment = Segment(v,v);
    assert( testSegmentPolygon(segment, polygon)[0].distance == 1 );

    vec3 v2 = vec3(21,0,0);
    Segment segment2 = Segment(v2,v2);
    assert( testSegmentPolygon(segment2, polygon)[0].distance == 1 );

}
