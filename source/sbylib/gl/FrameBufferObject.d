module sbylib.gl.FrameBufferObject;

import sbylib.gl;
import derelict.opengl;

class FrameBufferObject {

    alias id this;

    immutable uint id;

    private int[4] viewportData; //writeBeginのときの一時保存用
    private int frameBufferData;
    private int texIdData;

    this() {
        uint id;
        glGenFramebuffers(1, &id);
        this.id = id;
    }

    ~this() {
        glDeleteBuffers(1, &id);
    }

    int fb;

    void bind() {
        int fb;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fb);
        if (fb != id) this.fb = fb;
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    void unBind() {
        glBindFramebuffer(GL_FRAMEBUFFER, fb);
    }

    void attachTextureAsColor(TextureObject tex) {
        bind();
        if (tex)
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex.texID, 0);
        else
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
        unBind();
    }

    void attachTextureAsDepth(TextureObject tex) {
        bind();
        if (tex)
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, tex.texID, 0);
        else
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
        unBind();
    }

    void attachRenderBufferObjectAsColor(RenderBufferObject rb) {
        bind();
        if (rb)
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rb.id);
        else
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, 0);
        unBind();
    }

    void attachRenderBufferObjectAsDepth(RenderBufferObject rb) {
        bind();
        if (rb)
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rb.id);
        else
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
        unBind();
    }

    void writeBegin(int width, int height) {
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &frameBufferData);
        bind();
        // "renderedTexture"を#0に結び付けられている色としてセットする
        glGetIntegerv(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER, &texIdData);

        // 描画バッファのリストをセットする
        uint DrawBuffers = GL_DEPTH_ATTACHMENT;

        glDrawBuffers(1, &DrawBuffers); // 1はDrawBufffersのサイズ

        glGetIntegerv(GL_VIEWPORT, viewportData.ptr);
        glViewport(0, 0, width, height);
    }

    void writeEnd() {
        glBindFramebuffer(GL_FRAMEBUFFER, frameBufferData);
        glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, texIdData, 0);
        glViewport(viewportData[0], viewportData[1], viewportData[2], viewportData[3]);
        unBind();
    }

    void write(int width, int height, void delegate() draw) {
        writeBegin(width, height);
        draw();
        writeEnd();
    }
}
