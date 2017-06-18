import std.stdio;
import std.math;

import sbylib;

import derelict.opengl;

void main() {
    auto core = new Core();
    auto world = new World;
    auto mesh = new Mesh(Box.get(), new LambertMaterial());
    auto time = 0.0f;
    core.addProcess((proc){
        time += 0.006;
        auto c = cos(time);
        auto s = sin(time);
        world.camera.pos = vec3(5*s,2,5*c);
        world.camera.lookAt(vec3(0));
    });
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world.addMesh(mesh);
    auto image = ImageLoader.load("./Resource/d.png");
    auto image2 = ImageLoader.load("./Resource/go.png");
    auto utex = new utexture("tex");
    auto utex2 = new utexture("tex2");
    utex.value = Utils.generateTexture(image);
    utex2.value = Utils.generateTexture(image2);
    mesh.mat.setUniform(() => utex);
    mesh.mat.setUniform(() => utex2);
    Viewport viewport = new Viewport(0,0, core.getWindow().getWidth(), core.getWindow().getHeight());
    RenderTarget renderTarget = new RenderTarget(256, 256);
    renderTarget.attachTexture!ubyte(FrameBufferAttachType.Color0);
    renderTarget.attachRenderBuffer(FrameBufferAttachType.Depth);
    utex2.value = renderTarget.getColorTexture();
    core.addProcess((proc) {
        world.render(viewport);
    });
    auto viewport2 = new Viewport(0,0,renderTarget.width, renderTarget.height);
    core.addProcess((proc) {
        world.render(viewport2, renderTarget);
    });
    core.start();
}
