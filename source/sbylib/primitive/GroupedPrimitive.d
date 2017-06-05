module sbylib.primitive.GroupedPrimitive;

import sbylib.primitive;
import sbylib.math;
import sbylib.utils;

import std.algorithm;

class GroupedPrimitive : Primitive {

    class ChildInfo {
        Primitive prim;
        vec3 relativePosition;
        quat relativeOrientation;
    }

    private {
        LinkList!ChildInfo mChildren;
    }

    this(Primitive[] children, vec3 origin) {
        foreach (child; children) {
            auto t = child.Position - origin;
            ChildInfo info = new ChildInfo;
            info.prim = child;
            info.relativePosition = t;
            info.relativeOrientation = child.Orientation;
            mChildren.push(info);
            child.Position = t;
        }
        Position = origin;
        super();
    }


    override {
        //実現不可能
        FaceList getFaceList() {
            assert(false);
        }

        CustomObject getCustom() {
            assert(false);
        }

        void updatePositionList(vec3[] posList) {
            assert(false);
        }

        //全員ぶん回すだけ
        bool step() {
            auto it = mChildren.iterator;
            while (it.hasNext) {
                auto next = it.next;
                if (next.prim.step() == false)
                    it.remove;
            }
            return mChildren.length > 0; //子供がいたら生存
        }

        void cacheTransform() {
            mChildren.each!(a => a.prim.cacheTransform());
        }

        //Primitive本来の機能に+あるふぁ
        @property {
            const(vec3) Position(vec3 p) {
                auto result = super.Position(p);

                auto it = mChildren.iterator;
                while (it.hasNext) {
                    auto child = it.next;
                    child.prim.Position = Position + rotate(child.relativePosition, Orientation);
                }
                return result;
            }

            const(quat) Orientation(quat q) {
                auto result = super.Orientation(q);

                auto it = mChildren.iterator;
                while (it.hasNext) {
                    auto child = it.next;
                    child.prim.Position = Position + rotate(child.relativePosition, Orientation);
                    child.prim.Orientation = Orientation * child.relativeOrientation;
                }
                return result;
            }

            const(vec3) Position() {
                return super.Position;
            }

            const(quat) Orientation() {
                return super.Orientation;
            }
        }
    }
}
