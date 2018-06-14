module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto internalWorld = new World;


    auto renderTarget = new RenderTarget(window.width, window.height);
    renderTarget.setClearColor(vec4(1));
    renderTarget.attachTexture!uint(FrameBufferAttachType.Color0);
    renderTarget.attachRenderBuffer!uint(FrameBufferAttachType.Depth);


    auto camera = new PerspectiveCamera(
            window.width / window.height, /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */
    );
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));
    world.configure3D(camera);


    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */
    auto planeEntity = new Entity(Plane.create(100,100), planeMat);
    world.add(planeEntity);


    auto boxEntity = makeEntity(Box.create(), new TextureMaterial);
    boxEntity.pos = vec3(0,2,0);
    boxEntity.scale = vec3(2);
    boxEntity.texture = renderTarget.getColorTexture;
    world.add(boxEntity);



    auto boxEntity2 = new Entity(Box.create(), new NormalMaterial);
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
    internalWorld.configure3D(camera2, renderTarget);


    CameraControl.attach(camera);


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.start();
}
