module sbylib.collision.CollisionMesh;

import std.math;
import std.variant;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.mesh.Object3D;
import sbylib.collision.CollisionInfo;
import sbylib.collision.geometry.CollisionCapsule;
import sbylib.collision.geometry.CollisionPolygon;

alias CollisionGeometry = Algebraic!(CollisionCapsule, CollisionPolygon);

class CollisionMesh {
    Variant userData;
    CollisionGeometry geom;

    this(Geom)(Geom geom) if (CollisionGeometry.allowed!Geom) {
        this.geom = geom;
    }

    CollisionInfo collide(CollisionMesh mesh) {
        CollisionInfo info;
        if (this.geom.type == typeid(CollisionCapsule)) {
            auto cap = *this.geom.peek!CollisionCapsule;
            if (mesh.geom.type == typeid(CollisionCapsule)) {
                auto cap2 = *mesh.geom.peek!CollisionCapsule;
                info = collide(cap, cap2);
            } else if (mesh.geom.type == typeid(CollisionPolygon)) {
                auto pol = *mesh.geom.peek!CollisionPolygon;
                info = collide(cap, pol);
            } else {
                assert(false);
            }
        } else if (this.geom.type == typeid(CollisionPolygon)) {
            auto pol = *this.geom.peek!CollisionPolygon;
            if (mesh.geom.type == typeid(CollisionCapsule)) {
                auto cap = *mesh.geom.peek!CollisionCapsule;
                info = collide(cap, pol);
            } else if (mesh.geom.type == typeid(CollisionPolygon)) {
                auto pol2 = *mesh.geom.peek!CollisionPolygon;
                info = collide(pol, pol2);
            } else {
                assert(false);
            }
        } 
        info.mesh1 = this;
        info.mesh2 = mesh;
        return info;
    }

    public static CollisionInfo collide(CollisionCapsule capsule1, CollisionCapsule capsule2) {
        CollisionInfo info;
        info.collided = segDistance(capsule1.start, capsule1.end, capsule2.start, capsule2.end) <= capsule1.radius + capsule2.radius;
        return info;
    }

    public static CollisionInfo collide(CollisionCapsule capsule, CollisionPolygon polygon) {
        CollisionInfo info;
        info.collided = polySegDistance(capsule.start, capsule.end, polygon.positions[0], polygon.positions[1], polygon.positions[2], polygon.normal) <= capsule.radius;
        return info;
    }

    public static CollisionInfo collide(CollisionPolygon polygon1, CollisionPolygon polygon2) {
        CollisionInfo info;
        info.collided = polygonDetection(polygon1, polygon2);
        return info;
    }

    alias clamp =
        (val, min, max) => val < min ? min :
                           val > max ? max :
                           val;

    private static float segDistance(vec3 s1, vec3 e1, vec3 s2, vec3 e2) {
        vec3 v1 = normalize(e1 - s1);
        vec3 v2 = normalize(e2 - s2);
        float d1 = dot(s2 - s1, v1);
        float d2 = dot(s2 - s1, v2);
        float dv = dot(v1, v2);
        float denom = 1 - dv * dv;
        if (denom > 0) {
            denom = 1 / denom;
            float t1 = (d1 - dv * d2) * denom;
            float t2 = (d1 * dv - d2) * denom;
            if (0 <= t1 && t1 <= 1) {
                if (0 <= t2 && t2 <= 1) {
                    // line & line
                    vec3 p1 = s1 + t1 * v1;
                    vec3 p2 = s2 + t2 * v2;
                    return length(p1 - p2);
                } else {
                    // line & point
                    t2 = clamp(t2, 0, 1);
                    vec3 p2 = s2 + t2 * v2;
                    return segPointDistance(s1, v1, p2);
                }
            } else {
                if (0 <= t2 && t2 <= 1) {
                    // line & point
                    t1 = clamp(t1, 0, 1);
                    vec3 p1 = s1 + t1 * v1;
                    return segPointDistance(s2, v2, p1);
                } else {
                    t1 = clamp(t1, 0, 1);
                    t2 = clamp(t2, 0, 1);
                    vec3 p1 = s1 + t1 * v1;
                    vec3 p2 = s2 + t2 * v2;
                    return length(p1 - p2);
                }
            }
        }
        // parallel
        return length(s1 - s2);
    }

    private static float segPointDistance(vec3 s, vec3 v, vec3 p) {
        v = normalize(v);
        float t = dot(p - s, v);
        return length(s + t * v - p);
    }

    private static float polySegDistance(vec3 s, vec3 e, vec3 p0, vec3 p1, vec3 p2, vec3 n) {
        import std.algorithm;
        import std.stdio;
        vec3 v = e - s;
        float dist = min(
                segDistance(s, e, p0, p1),
                segDistance(s, e, p1, p2),
                segDistance(s, e, p2, p0));
        float denom = dot(v, n);
        if (denom != 0) {
            float t1 = dot(p0 - s, n) / denom;
            // point & polygon
            t1 = clamp(t1, 0, 1);
            vec3 p = s + t1 * v;
            auto s0 = dot(n, cross(p1 - p0, p0 - p));
            auto s1 = dot(n, cross(p2 - p1, p1 - p));
            auto s2 = dot(n, cross(p0 - p2, p2 - p));
            if (s0 > 0 && s1 > 0 && s2 > 0
                || s0 < 0 && s1 < 0 && s2 < 0) {
                vec3 pn = p - n * dot(p-p0, n);
                dist = min(dist, abs(dot(p - p0, n)));
            }
        } else {
            auto s0 = dot(n, cross(p1 - p0, p0 - s));
            auto s1 = dot(n, cross(p2 - p1, p1 - s));
            auto s2 = dot(n, cross(p0 - p2, p2 - s));
            if (s0 > 0 && s1 > 0 && s2 > 0
                || s0 < 0 && s1 < 0 && s2 < 0) {
                vec3 pn = s - n * dot(s-p0, n);
                dist = min(dist, abs(dot(s - p0, n)));
            } else {
                s0 = dot(n, cross(p1 - p0, p0 - e));
                s1 = dot(n, cross(p2 - p1, p1 - e));
                s2 = dot(n, cross(p0 - p2, p2 - e));
                if (s0 > 0 && s1 > 0 && s2 > 0
                     || s0 < 0 && s1 < 0 && s2 < 0) {
                    vec3 pn = s - n * dot(s-p0, n);
                    dist = min(dist, abs(dot(s - p0, n)));
                }
            }
        }
        return dist;
    }

    private static bool polygonDetection(CollisionPolygon poly1, CollisionPolygon poly2) {
        //v = 交差直線のベクトル
        vec3 v = cross(poly1.normal, poly2.normal);
        if (v.x == 0 && v.y == 0 && v.z == 0) return false;
        float d0 = dot(poly1.positions[0] - poly2.positions[0], poly2.normal);
        float d1 = dot(poly1.positions[1] - poly2.positions[0], poly2.normal);
        float d2 = dot(poly1.positions[2] - poly2.positions[0], poly2.normal);
        // どっちかに寄ってたら当たっていない
        if (d0 > 0 && d1 > 0 && d2 > 0) return false;
        if (d0 < 0 && d1 < 0 && d2 < 0) return false;
        // poly1の各辺と面2との交点を求める
        vec3 p0, p1;
        mixin(() {
            import std.format;
            string str;
            foreach (i; 0..3) {
                auto a = i;
                auto b = (i+1) % 3;
                auto c = (i+2) % 3;
                str ~= format!"if (d%d > 0 && d%d > 0 && d%d <= 0) {"(a,b,c);
                    str ~= format!"p0 = poly1.positions[%d] + (poly1.positions[%d] - poly1.positions[%d]) * (d%d / (d%d - d%d));"(a,c,a,a,a,c);
                    str ~= format!"p1 = poly1.positions[%d] + (poly1.positions[%d] - poly1.positions[%d]) * (d%d / (d%d - d%d));"(b,c,b,b,b,c);
                str ~= "}";
                str ~= format!"if (d%d <= 0 && d%d <= 0 && d%d > 0) {"(a,b,c);
                    str ~= format!"p0 = poly1.positions[%d] + (poly1.positions[%d] - poly1.positions[%d]) * (d%d / (d%d - d%d));"(a,c,a,a,a,c);
                    str ~= format!"p1 = poly1.positions[%d] + (poly1.positions[%d] - poly1.positions[%d]) * (d%d / (d%d - d%d));"(b,c,b,b,b,c);
                str ~= "}";
            }
            return str;
        }());
        d0 = dot(poly2.positions[0] - poly1.positions[0], poly1.normal);
        d1 = dot(poly2.positions[1] - poly1.positions[0], poly1.normal);
        d2 = dot(poly2.positions[2] - poly1.positions[0], poly1.normal);
        // どっちかに寄ってたら当たっていない
        if (d0 > 0 && d1 > 0 && d2 > 0) return false;
        if (d0 < 0 && d1 < 0 && d2 < 0) return false;
        // poly2の各辺と面1との交点を求める
        vec3 p2, p3;
        mixin(() {
            import std.format;
            string str;
            foreach (i; 0..3) {
                auto a = i;
                auto b = (i+1) % 3;
                auto c = (i+2) % 3;
                str ~= format!"if (d%d > 0 && d%d > 0 && d%d <= 0) {"(a,b,c);
                    str ~= format!"p2 = poly2.positions[%d] + (poly2.positions[%d] - poly2.positions[%d]) * (d%d / (d%d - d%d));"(a,c,a,a,a,c);
                    str ~= format!"p3 = poly2.positions[%d] + (poly2.positions[%d] - poly2.positions[%d]) * (d%d / (d%d - d%d));"(b,c,b,b,b,c);
                str ~= "}";
                str ~= format!"if (d%d <= 0 && d%d <= 0 && d%d > 0) {"(a,b,c);
                    str ~= format!"p2 = poly2.positions[%d] + (poly2.positions[%d] - poly2.positions[%d]) * (d%d / (d%d - d%d));"(a,c,a,a,a,c);
                    str ~= format!"p3 = poly2.positions[%d] + (poly2.positions[%d] - poly2.positions[%d]) * (d%d / (d%d - d%d));"(b,c,b,b,b,c);
                str ~= "}";
            }
            return str;
        }());

        // 各pのv方向での射影が重なっているかどうかで最終的な判定
        float t0 = dot(p0, v);
        float t1 = dot(p1, v);
        float t2 = dot(p2, v);
        float t3 = dot(p3, v);
        float min0 = t0 < t1 ? t0 : t1;
        float max0 = t0 < t1 ? t1 : t0;
        float min1 = t2 < t3 ? t2 : t3;
        float max1 = t2 < t3 ? t3 : t2;
        if (max0 < min1) return false;
        if (max1 < min0) return false;
        return true;
    }
}
