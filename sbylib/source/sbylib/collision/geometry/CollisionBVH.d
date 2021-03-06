module sbylib.collision.geometry.CollisionBVH;

import sbylib.collision.geometry;

class CollisionBVH : CollisionGeometry {

    private {

        import sbylib.entity.Entity;
        import sbylib.math.Vector;
        import sbylib.utils.Change;

        struct GeomWithCenter {
            CollisionGeometry geom;
            vec3 center;
        }

        class INode {
            abstract void setOwner(Entity);
            abstract void collide(ref Array!CollisionInfo, CollisionGeometry);
            abstract void collide(ref Array!CollisionInfoRay, CollisionRay);
            abstract ChangeObserveTarget!AABB getBound();
        };

        class Node : INode {
            
            import std.algorithm : map, reduce;

            INode[] children;
            private ChangeObservedArray!AABB bounds;

            Depends!((const AABB[] bounds) => AABB(bounds.map!(b => b.min).reduce!minVector, bounds.map!(b => b.max).reduce!maxVector)) bound;

            this(INode[] children) {
                import std.array : array;

                this.children = children;
                this.bounds = ChangeObservedArray!(AABB)(children.map!(c => c.getBound()).array);
                this.bound.depends(this.bounds);
            }

            override void setOwner(Entity owner) {
                import std.algorithm : each;

                children.each!(child => child.setOwner(owner));
            }

            override void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
                if (!this.bound.collide(geom.getBound())) return;
                foreach (child; this.children) {
                    child.collide(result, geom);
                }
            }

            override void collide(ref Array!CollisionInfoRay result, CollisionRay ray) {
                if (!this.bound.collide(ray)) return;
                foreach (child; this.children) {
                    child.collide(result, ray);
                }
            }

            override ChangeObserveTarget!AABB getBound() {
                return this.bound.getTarget();
            }
        }

        class Leaf : INode {
            CollisionGeometry geom;

            this(CollisionGeometry geom) {
                this.geom = geom;
            }

            override void setOwner(Entity owner) {
                this.geom.setOwner(owner);
            }

            override void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
                if (!this.geom.getBound().collide(geom.getBound())) return;
                CollisionEntry.collide(result, this.geom, geom);
            }

            override void collide(ref Array!CollisionInfoRay result, CollisionRay ray) {
                if (!this.geom.getBound().collide(ray)) return;
                CollisionEntry.collide(result, this.geom, ray);
            }

            override ChangeObserveTarget!AABB getBound() {
                return this.geom.getBound();
            }
        }

        INode buildWithTopDown(GeomWithCenter[] geomCenterList) {
            import std.algorithm : map, sort;
            import std.array : array, empty;

            assert(geomCenterList.length > 0);
            if (geomCenterList.length == 1) return new Leaf(geomCenterList[0].geom);
            // calculate most long vector in the center points of geometries.
            vec3[3] basisCandidates = mostDispersionBasis(geomCenterList.map!(g => g.center).array);
            GeomWithCenter[] geomCenterList2;
            float len = -114514;
            vec3 basis;

            foreach (bc; basisCandidates) {
                // sort object along the most dispersion basis
                auto sorted = geomCenterList.sort!((a,b) => dot(a.center, bc) < dot(b.center, bc)).array;
                // calc length on the b
                float len2 = dot(sorted[$-1].center - sorted[0].center, bc);

                if (len2 > len) {
                    len = len2;
                    geomCenterList2 = sorted;
                    basis = bc;
                }
            }

            // separate objects at the center of the basis.
            auto origin = geomCenterList2[0].center.dot(basis);
            GeomWithCenter[] before, after;
            while (!geomCenterList2.empty) {
                auto middle = geomCenterList2[$/2];
                auto coord = dot(middle.center, basis) - origin;
                if (coord < len /2) {
                    before ~= geomCenterList2[0..$/2+1];
                    geomCenterList2 = geomCenterList2[$/2+1..$];
                } else {
                    after ~= geomCenterList2[$/2..$];
                    geomCenterList2 = geomCenterList2[0..$/2];
                }
            }
            if (before.length == 0) {
                assert(after.length > 0);
                if (after.length == 1) return new Leaf(after[0].geom);
                before = after[0..$/2];
                after = after[$/2..$];
            }
            if (after.length == 0) {
                assert(before.length > 0);
                if (before.length == 1) return new Leaf(before[0].geom);
                after = before[$/2..$];
                before = before[0..$/2];
            }
            assert(before.length > 0);
            assert(after.length > 0);
            auto beforeNode = buildWithTopDown(before);
            auto afterNode = buildWithTopDown(after);
            auto result = new Node([beforeNode, afterNode]);
            return result;
        }

        INode buildWithTopDown(CollisionGeometry[] geoms)
            in(geoms.length > 0)
        {
            import std.algorithm : map;
            import std.array : array;
            import std.functional : pipe;

            return buildWithTopDown(geoms.map!(g => GeomWithCenter(g, g.getBound().pipe!(aabb => (aabb.min + aabb.max) / 2))).array);
        }
    }


    private INode root;

    this(CollisionGeometry[] geoms)
        in(geoms.length > 0)
    {
        this.root = buildWithTopDown(geoms);
    }

    override void setOwner(Entity owner) {
        root.setOwner(owner);
    }

    override ChangeObserveTarget!AABB getBound() {
        return root.getBound();
    }

    void collide(ref Array!CollisionInfo result, CollisionGeometry geom) {
        this.root.collide(result, geom);
    }

    void collide(ref Array!CollisionInfoRay result, CollisionRay ray) {
        this.root.collide(result, ray);
    }

    override string toString() {
        return typeof(this).stringof;
    }
}
