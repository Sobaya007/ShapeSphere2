import std.stdio;
import std.math;

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
    foreach (floor; player.esphere.floors) {
        auto mat = new TextureMaterial();
        mat.texture = texture;
        world3d.addMesh(new Mesh(floor.createGeometry(), mat, floor.obj));
    }
    world3d.addMesh(player.esphere.mesh);
    PointLight pointLight;
    pointLight.pos = vec3(0,2,0);
    pointLight.diffuse = vec3(1);
    world3d.addPointLight(pointLight);

    CameraChaseControl control = new CameraChaseControl(world3d.camera, player.esphere.mesh.obj);

    core.addProcess((proc) {
        player.esphere.move();
        player.step();
        control.step();
        if (core.getKey(KeyButton.Escape)) core.end();
        if (core.getKey(KeyButton.KeyR)) ConstantManager.reload();
    });

    core.start();
}
