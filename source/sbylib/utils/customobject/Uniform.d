module sbylib.utils.customobject.Uniform;

package class Uniform {
    int loc;
    float[] arguments;

    abstract void apply() @nogc;
}
