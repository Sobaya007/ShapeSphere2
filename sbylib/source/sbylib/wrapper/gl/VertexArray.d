module sbylib.wrapper.gl.VertexArray;

import sbylib.wrapper.gl.ObjectGL;

class VertexArray : ObjectGL {

    import sbylib.wrapper.gl.Attribute;
    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;
    import sbylib.wrapper.gl.Program;
    import sbylib.wrapper.gl.IndexBuffer;
    import sbylib.wrapper.gl.VertexBuffer;
    import std.typecons : Tuple;

    this() {
        super(GlUtils.genVertexArray());
    }

    override void destroy()
        in(isAlive())
    {
        super.destroy();
        GlUtils.deleteVertexArray(this.id);
    }

    void bind() const
        in(isAlive())
    {
        GlFunction.bindVertexArray(this.id);
    }

    void unbind() const
        in(isAlive())
    {
        GlFunction.bindVertexArray(0);
    }

    void setup(const Program program, Tuple!(Attribute, VertexBuffer)[] buffers, IndexBuffer ibo) {
        this.bind();
        foreach(tuple; buffers) {
            if (!program.hasAttribute(tuple[0].name)) continue;
            program.enableAttribute(tuple[0]);
            tuple[1].bind();
            program.attachAttribute(tuple[0], tuple[1]);
        }
        ibo.bind();
        this.unbind();
    }

    void drawArrays(Prim prim, uint offset, uint count) {
        this.bind();
        GlFunction.drawArrays(prim, offset, count);
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, IndexType[] indices)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        GlFunction.drawElements(prim, indices.length, indices.ptr);
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, uint count)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        GlFunction.drawElements!(IndexType)(prim, count, null);
        this.unbind();
    }
}
