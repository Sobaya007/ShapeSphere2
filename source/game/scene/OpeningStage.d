module game.scene.OpeningStage;

import game.scene.SceneBase;
import game.GameMain;
import game.player.Player;
import sbylib;
import std.stdio;

class OpeningStage : SceneBase {

    mixin SceneBasePack;

    this() {
        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 100);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        super(camera);
    }

    override void initialize() {
        auto core = Core();

        auto texture = Utils.generateTexture(ImageLoader.load(ImagePath("uv.png")));
        /* Player Settings */
        auto commandManager = getCommandManager([""]);
        Player player = new Player(camera, world, commandManager);
        core.addProcess((proc) {
            player.step();
        }, "player update");
        core.addProcess(&commandManager.update, "command update");

        /* Polygon(Floor) Settings */
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
            addEntity(e0);
            addEntity(e1);
            player.floors.addChild(e0);
            player.floors.addChild(e1);
        };
        makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
        makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);

        /* Light Settings */
        PointLight pointLight;
        pointLight.pos = vec3(0,2,0);
        pointLight.diffuse = vec3(1);
        world.addPointLight(pointLight);
    }
}
