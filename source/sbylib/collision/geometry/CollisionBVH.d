module sbylib.collision.geometry.CollisionBVH;

import sbylib.collision.geometry;
import sbylib.entity.Entity;
import sbylib.utils;
import std.algorithm, std.functional, std.array, std.typecons;
import sbylib.math;

class CollisionBVH : CollisionGeometry {

    private {

        struct GeomWithCenter {
            CollisionGeometry geom;
            vec3 center;
        }

        class INode {
            AABB bound;

            abstract void setOwner(Entity);
            abstract void collide(ref Array!CollisionInfo, CollisionGeometry);
        };

        class Node : INode {
            INode[] children;

            this(INode[] children) {
                this.children = children;
                import std.algorithm, std.array;
                this.bound = AABB(
                    children.map!(child => child.bound.min).reduce!minVector,
                    children.map!(child => child.bound.max).reduce!maxVector
                );
            }

            override void setOwner(Entity owner) {
                children.each!(child => child.setOwner(owner));
            }

            override void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
                if (!this.bound.collide(geom.getBound())) return;
                foreach (child; this.children) {
                    child.collide(result, geom);
                }
            }
        }

        class Leaf : INode {
            CollisionGeometry geom;

            this(CollisionGeometry geom) {
                this.geom = geom;
                this.bound = geom.getBound();
            }

            override void setOwner(Entity owner) {
                this.geom.setOwner(owner);
            }

            override void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
                if (!this.geom.getBound().collide(geom.getBound())) return;
                CollisionEntry.collide(result, this.geom, geom);
            }
        }

        INode buildWithTopDown(GeomWithCenter[] geomCenterList) {
            if (geomCenterList.length == 1) return new Leaf(geomCenterList[0].geom);
            // calculate most long vector in the center points of geometries.
            vec3 basis = Utils.mostDispersionBasis(geomCenterList.map!(g => g.center).array)[0];

            // sort object along the most dispersion basis
            auto sorted = geomCenterList.sort!((a,b) => dot(a.center, basis) < dot(b.center, basis)).array;
// calc length on the basis
            auto len = dot(sorted[$-1].center - sorted[0].center, basis);

            // separate objects at the center of the basis.
            auto origin = sorted[0].center.dot(basis);
            GeomWithCenter[] before, after;
            while (!sorted.empty) {
                auto middle = sorted[$/2];
                if (dot(middle.center, basis) - origin < len /2) {
                    before ~= sorted[0..$/2+1];
                    sorted = sorted[$/2+1..$];
                } else {
                    after ~= sorted[$/2..$];
                    sorted = sorted[0..$/2];
                }
            }
            auto beforeNode = buildWithTopDown(before);
            auto afterNode = buildWithTopDown(after);
            auto result = new Node([beforeNode, afterNode]);
            return result;
        }

        INode buildWithTopDown(CollisionGeometry[] geoms) {
            return buildWithTopDown(geoms.map!(g => GeomWithCenter(g, g.getBound().pipe!(aabb => (aabb.min + aabb.max) / 2))).array);
        }
    }

    private INode root;

    override void setOwner(Entity owner) {
        root.setOwner(owner);
    }

    override AABB getBound() {
        return root.bound;
    }

    void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
        this.root.collide(result, geom);
    }
}
