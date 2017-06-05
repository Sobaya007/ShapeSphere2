module sbylib.entity.StepManager;

import sbylib;
import std.traits, std.range, std.algorithm, std.conv;

/*
   Entityを実装するものを管理します。
   Singletonなので、getInstanceを経由して使用します。

   stepAllは使用しないでください。
 */

alias Step = bool delegate();

class StepManager {
    private this(){}

    private static {

        LinkList!(Step)[100] entityList;

        void step(uint i) {
            auto it = entityList[i].iterator;
            while (it.hasNext) {
                auto next = it.next;
                if (next() == false)
                    it.remove;
            }
        }

    }

    public static {

        void stepAll() {
            maxPriority.iota.each!(i => step(i));
        }

        uint maxPriority() {
            return entityList.length;
        }

        void add(bool delegate() step, uint priority = 50) in {
            assert(0 <= priority && priority < entityList.length, "Specified Priority " ~ to!string(priority) ~ " Is Out Of Range. Max Priority is " ~ to!string(maxPriority));
        } body{
            entityList[priority].push(step);
        }

        void add(void delegate() step, uint priority = 50) {
            add({
                step();
                return true;
            }, priority);
            }

            void add(T)(T obj, uint priority = 50) 
            if (__traits(hasMember, T, "step") 
                 && (is(ReturnType!(obj.step) == bool) || is (ReturnType!(obj.step) == void))) {
                add(&obj.step, priority);
            }
    }
}

class StackedStepper {
    private Stack!Step stack;
    private static StackedStepper[string] instanceList;

    private this(){}

    static StackedStepper getInstance(string name, uint priority = 50) {
        auto p = name in instanceList;
        if(p) return *p;
        auto ins = new StackedStepper();
        instanceList[name] = ins;
        StepManager.add(ins, priority);
        return ins;
    }

    bool step() {
        if (stack.isEmpty()) return false;
        auto first = stack.getLast;
        if (!first()) stack.pop;
        return true;
    }

    void push(bool delegate() func) {
        stack.push(func);
    }

}
