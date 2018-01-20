module game.enemy.Boxlime;

import sbylib;
import game.enemy.Enemy;
import game.Game;

class Boxlime : Enemy {

    private Entity entity;

    this() {
        new Face(0,+1);
        new Face(1,+1);
        new Face(2,+1);
        new Face(0,-1);
        new Face(1,-1);
        new Face(2,-1);
    }

    class Face {

        private GeometryNT geom;

        this(uint offset, int sign) {
            vec3 rotate(vec3 v) {
                foreach (i; 0..3) {
                    v[i] = v[(i+offset)%3];
                }
                return v;
            }
            this.geom = new GeometryNT([
                new VertexNT(sign * rotate(vec3(+1,+1,+1)), sign * rotate(vec3(0,1,0)), vec2(+1,+1)),
                new VertexNT(sign * rotate(vec3(+1,+1,-1)), sign * rotate(vec3(0,1,0)), vec2(+1, 0)),
                new VertexNT(sign * rotate(vec3(-1,+1,-1)), sign * rotate(vec3(0,1,0)), vec2( 0, 0)),
                new VertexNT(sign * rotate(vec3(-1,+1,+1)), sign * rotate(vec3(0,1,0)), vec2( 0,+1)),
            ], [0,1,2,3]);

            auto mat = new ColorMaterial;
            mat.color = vec4(1,0,1,1);
            auto entity = new Entity(geom, mat);

            Game.getWorld3D().add(entity);
        }
    }

}
