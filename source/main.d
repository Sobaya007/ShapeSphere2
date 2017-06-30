import std.stdio;
import std.math;
import std.algorithm;
import std.array;

import sbylib;
import player.ElasticSphere;
import player.Player;

void main() {
    auto core = new Core();

    auto world3d = new World;
    world3d.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world3d.camera.getObj().pos = vec3(3, 2, 9);
    world3d.camera.getObj().lookAt(vec3(0,2,0));

    auto world2d = new World;
    world2d.camera = new OrthoCamera(2,2,-1,1);

    core.addProcess((proc) {
        world3d.render(core.getWindow().getRenderTarget());
        clear(ClearMode.Depth);
        world2d.render(core.getWindow().getRenderTarget());
    });

    auto texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));
    Player player = new Player(core.getWindow(), world3d.camera);

    auto makePolygon = (vec3[4] p) {
        auto polygons = [
        new CollisionPolygon([p[0], p[1], p[2]]),
        new CollisionPolygon([p[0], p[2], p[3]])];
        auto mat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
        mat.ambient1 = vec3(1);
        mat.ambient2 = vec3(0);
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

        player.esphere.floors ~= polygons.map!(c => new CollisionMesh(c)).array;
        world3d.addMesh(new Mesh(geom0, mat, polygons[0].obj));
        world3d.addMesh(new Mesh(geom1, mat, polygons[1].obj));
    };
    makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
    makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);
    world3d.addMesh(player.esphere.mesh);
    PointLight pointLight;
    pointLight.pos = vec3(0,2,0);
    pointLight.diffuse = vec3(1);
    world3d.addPointLight(pointLight);

    CameraChaseControl control = new CameraChaseControl(world3d.camera, player.esphere.mesh.obj);

    auto fpsCounter = new FpsCounter!100();
    import std.format;

    core.addProcess((proc) {
        fpsCounter.update();
        core.getWindow().setTitle(format!"FPS[%d]"(fpsCounter.getFPS()));
        player.esphere.move();
        player.step();
        control.step();
        if (core.getKey(KeyButton.Escape)) core.end();
        if (core.getKey(KeyButton.KeyR)) ConstantManager.reload();
        if (core.getKey(KeyButton.KeyW)) player.esphere.mesh.mat.config.polygonMode = PolygonMode.Line;
        else player.esphere.mesh.mat.config.polygonMode = PolygonMode.Fill;
        player.esphere.condition = !core.getKey(KeyButton.Enter);
    });

    core.start();
}
