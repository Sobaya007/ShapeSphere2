module sbylib.material.RenderConfig;

public {
    import sbylib.wrapper.gl.Constants;
}
import sbylib.wrapper.gl.Functions;

class RenderConfig {
    TestFunc depthFunc;
    PolygonMode polygonMode;
    FaceMode faceMode;
    TestFunc stencilFunc;
    uint stencilValue;
    uint stencilMask;
    StencilWrite sfail, dpfail, pass;
    BlendFactor srcFactor, dstFactor;
    BlendEquation blendEquation;
    bool depthWrite, depthTest;
    float lineWidth;
    string renderGroupName;

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
        this.depthWrite = true;
        this.depthTest = true;
        this.lineWidth = 1f;
        this.renderGroupName = "regular";
    }

    void set() {
        GlFunction.depthFunc(this.depthFunc);
        GlFunction.faceSetting(this.polygonMode, this.faceMode);
        GlFunction.stencil(this.stencilFunc, this.stencilValue, this.stencilMask, this.sfail, this.dpfail, this.pass);
        GlFunction.blendFunc(this.srcFactor, this.dstFactor);
        GlFunction.blendEquation(this.blendEquation);
        GlFunction.depthWrite(this.depthWrite);
        GlFunction.depthTest(this.depthTest);
        GlFunction.lineWidth(this.lineWidth);
    }
}
