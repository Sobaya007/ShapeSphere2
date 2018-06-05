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
    TestFunc stencilFunc;
    uint stencilValue;
    uint stencilMask;
    StencilWrite sfail, dpfail, pass;
    bool blend;
    BlendFactor srcFactor, dstFactor;
    BlendEquation blendEquation;
    bool depthWrite, depthTest;
    float lineWidth;
    string renderGroupName;
    void delegate(void delegate()) process;

    this() {
        this.depthFunc = TestFunc.Less;
        this.polygonMode = PolygonMode.Fill;
        this.faceMode = FaceMode.Front;
        this.stencilFunc = stencilFunc.Always;
        this.stencilValue = 1;
        this.stencilMask = 1;
        this.sfail = StencilWrite.Keep;
        this.dpfail = StencilWrite.Keep;
        this.pass = StencilWrite.Keep;
        this.srcFactor = BlendFactor.SrcAlpha;
        this.dstFactor = BlendFactor.OneMinusSrcAlpha;
        this.blendEquation = BlendEquation.Add;
        this.blend = true;
        this.depthWrite = true;
        this.depthTest = true;
        this.lineWidth = 1f;
        this.renderGroupName = "regular";
        this.process = render => render();
    }

    void set() {
        GlFunction.depthFunc(this.depthFunc);
        GlFunction.faceSetting(this.polygonMode, this.faceMode);
        GlFunction.stencil(this.stencilFunc, this.stencilValue, this.stencilMask, this.sfail, this.dpfail, this.pass);
        GlFunction.blendFunc(this.srcFactor, this.dstFactor);
        GlFunction.blendEquation(this.blendEquation);
        if (blend) GlFunction.enable(Capability.Blend);
        else GlFunction.disable(Capability.Blend);
        GlFunction.depthWrite(this.depthWrite);
        GlFunction.depthTest(this.depthTest);
        GlFunction.lineWidth(this.lineWidth);
    }

    void render(void delegate() impl) {
        process(impl);
    }
}
