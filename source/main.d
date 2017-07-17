import std.stdio;
import std.math;
import std.algorithm;
import std.array;
import std.getopt;

import sbylib;
import player.ElasticSphere;
import player.Player;
import plot.Main;
import examples.example1;
import examples.example2;
import examples.text2d;
import examples.mouse;
import examples.material;
import examples.gui;

extern(C) __gshared string[] rt_options = ["gcopt=profile:1"];

void main(string[] args) {
    getopt(args, "mode", &runMode);
    final switch(runMode) {
    case RunMode.Game:
        //example1();
        //example2();
        //mainMaterial();
        //mainGUI();
        //mainText2d();
        //mainMouse();
        gameMain();
        break;
    case RunMode.Plot:
        plotMain();
        break;
    }
}

void gameMain() {
    auto core = Core();
    auto screen = core.getWindow().getRenderTarget();

    auto world3d = new Bahamut;
    world3d.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world3d.camera.getObj().pos = vec3(3, 2, 9);
    world3d.camera.getObj().lookAt(vec3(0,2,0));

    auto world2d = new Bahamut;
    world2d.camera = new OrthoCamera(2,2,-1,1);

    core.addProcess((proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world3d.render(screen);
        screen.clear(ClearMode.Depth);
        world2d.render(screen);
    }, "render");

    auto texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));
    Player player = new Player(core.getWindow(), world3d.camera);

    auto makePolygon = (vec3[4] p) {
        auto polygons = [
        new CollisionPolygon([p[0], p[1], p[2]]),
        new CollisionPolygon([p[0], p[2], p[3]])];
        auto mat = new CheckerMaterial!(NormalMaterial, UvMaterial);
        mat.size = 0.118;
        auto geom0 = polygons[0].createGeometry();
        geom0.vertices[0].uv = vec2(1,0);
        geom0.vertices[1].uv = vec2(1,1);
        geom0.vertices[2].uv = vec2(0,1);
        geom0.updateBuffer();
        auto geom1 = polygons[1].createGeometry();
        geom1.vertices[0].uv = vec2(1,0);
        geom1.vertices[1].uv = vec2(0,1);
        geom1.vertices[2].uv = vec2(0,0);
        geom1.updateBuffer();

        Entity e0 = new Entity(geom0, mat, polygons[0]);
        Entity e1 = new Entity(geom1, mat, polygons[1]);
        world3d.add(e0);
        world3d.add(e1);
        player.esphere.floors ~= e0;
        player.esphere.floors ~= e1;
    };
    makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
    makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);
    world3d.add(player.esphere.entity);
    PointLight pointLight;
    pointLight.pos = vec3(0,2,0);
    pointLight.diffuse = vec3(1);
    world3d.addPointLight(pointLight);

    CameraChaseControl control = new CameraChaseControl(world3d.camera, player.esphere.entity.obj);

    auto fpsCounter = new FpsCounter!100();
    import std.format;

    auto fpsLogger = new TimeLogger("FPS");

    core.addProcess((proc) {
        fpsCounter.update();
        fpsLogger.directWrite(fpsCounter.getFPS());
        core.getWindow().setTitle(format!"FPS[%d]"(fpsCounter.getFPS()));
    }, "fps update");
    core.addProcess((proc) {
        player.esphere.move();
        player.step();
        control.step();
    }, "player update");
    core.addProcess((proc) {
        if (core.getKey(KeyButton.Escape)) core.end();
        if (core.getKey(KeyButton.KeyR)) ConstantManager.reload();
        if (core.getKey(KeyButton.KeyW)) player.esphere.entity.getMesh().mat.config.polygonMode = PolygonMode.Line;
        else player.esphere.entity.getMesh().mat.config.polygonMode = PolygonMode.Fill;
        player.esphere.condition = !core.getKey(KeyButton.Enter);
    }, "last");

    core.start();
}
