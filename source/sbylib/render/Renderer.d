module sbylib.render.Renderer;

public {
    import sbylib.core.World;
    import sbylib.render.RenderTarget;
    import sbylib.render.Viewport;
    import sbylib.entity.Entity;
}

class Renderer {

    void render(World world, IRenderTarget renderTarget, IViewport viewport) {
        viewport.set();
        renderTarget.renderBegin();
        world.render();
        renderTarget.renderEnd();
    }

    void render(World world, IRenderTarget renderTarget, IViewport viewport, string renderGroupName) {
        viewport.set();
        renderTarget.renderBegin();
        world.render();
        renderTarget.renderEnd();
    }
}
