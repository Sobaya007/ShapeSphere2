module game.Map;

import sbylib;
import game.Game;
import model.xfile.loader;

class Map {
    private Entity polygons;

    alias getPolygon this;

    this() {
        this.polygons = new Entity;
        Game.getWorld3D().add(this.polygons);
    }

    void testStage() {
        auto makePolygon = (vec3[4] p) {
            auto polygons = [
                new CollisionPolygon([p[0], p[1], p[2]]),
                new CollisionPolygon([p[0], p[2], p[3]])
            ];
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
            this.polygons.addChild(e0);
            this.polygons.addChild(e1);
        };
        makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
        makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);
    }

    void testStage2() {
        auto loader = new XLoader();
        auto model = loader.load(ModelPath("test.x")).buildEntity();
        model.createCollisionPolygon();
        model.scale = vec3(3);
        this.polygons.addChild(model);
    }

    Entity getPolygon() {
        return this.polygons;
    }
}
