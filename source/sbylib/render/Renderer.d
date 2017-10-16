module sbylib.render.Renderer;

import sbylib.core.World;
import sbylib.render.RenderTarget;
import sbylib.render.Viewport;

class Renderer {

    void render(World world, IRenderTarget renderTarget, IViewport viewport) {
        viewport.set();
        renderTarget.renderBegin();
        world.render();
        renderTarget.renderEnd();
    }
}
