module sbylib.material.RenderConfig;

public {
    import sbylib.wrapper.gl.Constants;
}
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.VertexArray;

import sbylib.geometry.Geometry;

class RenderConfig {
    TestFunc depthFunc;
    PolygonMode polygonMode;
    FaceMode faceMode;
    bool blend;
    BlendFactor srcFactor, dstFactor;
    BlendEquation blendEquation;
    bool colorWrite;
    bool depthWrite, depthTest;
    TestFunc stencilFunc;
    bool stencilWrite;
    uint stencilValue;
    uint stencilMask;
    StencilWrite sfail, dpfail, pass;
    float lineWidth;
    string renderGroupName;
    void delegate(void delegate()) process;

    this() {
        this.depthFunc = TestFunc.Less;
        this.polygonMode = PolygonMode.Fill;
        this.faceMode = FaceMode.Front;
        this.srcFactor = BlendFactor.SrcAlpha;
        this.dstFactor = BlendFactor.OneMinusSrcAlpha;
        this.blendEquation = BlendEquation.Add;
        this.blend = true;
        this.colorWrite = true;
        this.depthWrite = true;
        this.depthTest = true;
        this.stencilWrite = false;
        this.stencilFunc = stencilFunc.Always;
        this.stencilValue = 1;
        this.stencilMask = ~0;
        this.sfail = StencilWrite.Keep;
        this.dpfail = StencilWrite.Keep;
        this.pass = StencilWrite.Keep;
        this.lineWidth = 1f;
        this.renderGroupName = "regular";
        this.process = render => render();
    }

    void set() {
        GlFunction.depthFunc(this.depthFunc);
        GlFunction.faceSetting(this.polygonMode, this.faceMode);
        GlFunction.blendFunc(this.srcFactor, this.dstFactor);
        GlFunction.blendEquation(this.blendEquation);
        if (blend) GlFunction.enable(Capability.Blend);
        else GlFunction.disable(Capability.Blend);
        GlFunction.colorWrite(this.colorWrite);
        GlFunction.depthWrite(this.depthWrite);
        GlFunction.depthTest(this.depthTest);
        GlFunction.stencilWrite(this.stencilWrite);
        GlFunction.stencil(this.stencilFunc, this.stencilValue, this.stencilMask, this.sfail, this.dpfail, this.pass);
        GlFunction.lineWidth(this.lineWidth);
    }

    void render(void delegate() impl) {
        process(impl);
    }
}
