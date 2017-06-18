module sbylib.geometry.Line;

import sbylib;

//class Line : Geometry {
//
//    private vec3 _start, _end;
//    private float[] mVertexArray;
//
//    this() {
//        this(vec3(0), vec3(0));
//    }
//
//    this(vec3 start, vec3 end)  {
//        this._start = start;
//        this._end = end;
//        this.mVertexArray = new float[6];
//        this.mVertexArray[0..3] = start.array;
//        this.mVertexArray[3..6] = end.array;
//
//        auto custom = new CustomObject(ShaderStore.getShader("SimpleColor"), Prim.Line);
//        custom.beginMesh;
//        custom.addAttribute!(3, "mVertex")(mVertexArray, GpuSendFrequency.Static);
//        custom.setIndex(cast(uint[])[0,1], GpuSendFrequency.Static);
//        custom.addDynamicUniformMatrix!(4, "mWorld")({return getWorldMatrix.array;});
//        //custom.addDynamicUniformMatrix!(4, "mViewProj")({return SbyWorld.currentCamera.getViewProjectionMatrix.array;});
//        custom.setUniform!(4, "color")([0,0,1,1]);
//        custom.endMesh;
//        super(custom);
//    }
//
//    override bool step() {
//        getCustom.draw();
//        return true;
//    }
//
//    void start(vec3 s) @property {
//        this._start = s;
//        this.mVertexArray[0..3] = s.array;
//        getCustom.update("mVertex", mVertexArray);
//    }
//
//    void end(vec3 e) @property {
//        this._end = e;
//        this.mVertexArray[3..6] = e.array;
//        getCustom.update("mVertex", mVertexArray);
//    }
//
//    vec3 start() @property {
//        return _start;
//    }
//
//    vec3 end() @property {
//        return _end;
//    }
//}
