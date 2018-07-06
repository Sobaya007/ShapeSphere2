module sbylib.wrapper.gl.VertexBuffer;

import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.Constants;

class VertexBuffer : BufferObject!(BufferType.Array, float) {

    import sbylib.wrapper.gl.Functions;
    import std.conv : to;

    final void asAttribute(uint dim, uint location) 
        in(1 <= dim && dim <= 4, "dimension must be 1 ~ 4. given " ~ to!string(dim))
    {
        this.bind();
        GlFunction.vertexAttribPointer!(float)(location, dim, false, 0, null);
        this.unbind();
    }

    final void asAttribute(uint stride, uint size, uint location) {
        this.bind();
        GlFunction.vertexAttribPointer!(float)(location, size, false, stride, null);
        this.unbind();
    }
}
