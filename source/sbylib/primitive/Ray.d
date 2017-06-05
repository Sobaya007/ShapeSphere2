module sbylib.primitive.Ray;

import sbylib.primitive;
import sbylib.math;
import sbylib.utils;
import sbylib.shadertemplates;
import sbylib.gl;
import sbylib.core;

import std.math;

class Ray : Primitive {
    private vec3 _start, _vector;
    private float[] mVertexArray;

    this() {
        this(vec3(0), vec3(0));
    }

    this(vec3 _start, vec3 _vector)  {

        this._start = _start;
        this._vector = _vector;
        this.mVertexArray = new float[6];
        this.mVertexArray[0..3] = _start.array;
        this.mVertexArray[3..6] = (_start + _vector * 114514).array;

        auto custom = new CustomObject(ShaderStore.getShader("SimpleColor"), Prim.Line);
        custom.beginMesh;
        custom.addAttribute!(3, "mVertex")(mVertexArray, GpuSendFrequency.Static);
        custom.setIndex(cast(uint[])[0,1], GpuSendFrequency.Static);
        custom.addDynamicUniformMatrix!(4, "mWorld")({return getWorldMatrix.array;});
        custom.addDynamicUniformMatrix!(4, "mViewProj")({return SbyWorld.currentCamera.getViewProjectionMatrix.array;});
        custom.setUniform!(4, "color")([0,0,1,1]);
        custom.endMesh;
        super(custom);
    }

    override bool step() {
        getCustom.draw();
        return true;
    }

    void start(vec3 s) @property {
        this._start = s;
        this.mVertexArray[0..3] = s.array;
        getCustom.update("mVertex", mVertexArray);
    }

    void vector(vec3 v) @property {
        this._vector = v;
        this.mVertexArray[3..6] = (_start+v * 114514).array;
        getCustom.update("mVertex", mVertexArray);
    }

    vec3 start() @property {
        return _start;
    }

    vec3 vector() @property {
        return _vector;
    }

    vec3 getNearestPoint(vec3 p) {
        float t = fmax(0, dot(p-Position, vector));
        return Position + vector * t;
    }

    float getDistance(vec3 p) {
        vec3 d = p - Position;
        float t = fmax(0, dot(d, vector));
        return length(vector * t - d);
    }
}
