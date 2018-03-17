module sbylib.wrapper.gl.VertexBuffer;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import std.conv;

class VertexBuffer : BufferObject!(BufferType.Array, float) {

    final void asAttribute(uint dim, uint location) {
        assert(1 <= dim && dim <= 4, "dimension must be 1 ~ 4. given " ~ to!string(dim));
        this.bind();
        glVertexAttribPointer(location, dim, GlFunction.getTypeEnum!(float), false, 0, null);
        GlFunction.checkError();
        this.unbind();
    }

    final void asAttribute(uint stride, uint size, uint location) {
        this.bind();
        glVertexAttribPointer(location, size, GlFunction.getTypeEnum!(float), false, stride, null);
        GlFunction.checkError();
        this.unbind();
    }
}