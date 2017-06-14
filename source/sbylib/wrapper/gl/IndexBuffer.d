module sbylib.wrapper.gl.IndexBuffer;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import std.conv;

class IndexBuffer : BufferObject!(BufferType.ElementArray, uint) {
}
