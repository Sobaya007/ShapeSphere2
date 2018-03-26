module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto world = new World;
    auto internalWorld = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


    auto renderTarget = new RenderTarget(window.getWidth, window.getHeight);
    renderTarget.setClearColor(vec4(1));
    renderTarget.attachTexture!uint(FrameBufferAttachType.Color0);
    renderTarget.attachRenderBuffer!uint(FrameBufferAttachType.Depth);


    auto camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */
    );
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));
    world.setCamera(camera);


    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */
    auto planeEntity = new Entity(Plane.create(100,100), planeMat);
    world.add(planeEntity);


    auto boxEntity = makeEntity(Box.create(10,10,10), new TextureMaterial);
    boxEntity.obj.pos = vec3(0,2,0);
    boxEntity.texture = renderTarget.getColorTexture;
    world.add(boxEntity);



    auto boxEntity2 = new Entity(Box.create(10,10,10), new NormalMaterial);
    internalWorld.add(boxEntity2);
    core.addProcess({ boxEntity2.rot *= mat3.axisAngle(vec3(1,1,1).normalize, 0.02.rad); }, "a");


    auto camera2 = new PerspectiveCamera(
            1, /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */
    );
    camera2.pos = vec3(1, 2, 3);
    camera2.lookAt(vec3(0,0,0));
    internalWorld.setCamera(camera2);


    auto control = new CameraControl(camera);
    core.addProcess(&control.update, "update");


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.addProcess({
        renderTarget.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(internalWorld, renderTarget, viewport);

        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}
