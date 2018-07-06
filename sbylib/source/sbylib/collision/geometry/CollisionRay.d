module sbylib.collision.geometry.CollisionRay;

import sbylib.math.Vector;
import sbylib.math.Matrix;

class CollisionRay {
    vec3 start;
    vec3 dir;

    import sbylib.camera;

    static CollisionRay get(vec2 screenPos, Camera camera) {
        static CollisionRay ray;
        if (ray is null) ray = new CollisionRay;
        ray.build(screenPos, camera);
        return ray;
    }

    void build(vec2 screenPos, Camera camera) {
        auto viewStart = projToView(vec3(screenPos, 0), camera.projMatrix);
        auto viewEnd = projToView(vec3(screenPos, 100), camera.projMatrix);

        mat4 viewInv = camera.worldMatrix;
        auto viewInv3 = viewInv.toMatrix3;

        this.start = (viewInv * vec4(viewStart, 1)).xyz;
        this.dir = -(mat3.transpose(viewInv3) * normalize(viewEnd - viewStart));
        // this.dir = viewInv3 * normalize(viewEnd - viewStart);
    }

    private vec3 projToView(vec3 projPos, mat4 proj) {
        auto projInv = mat4.invert(proj);
        auto row3 = projInv.row[3];

        auto projPos4 = vec4(projPos, 1);
        auto cs = 1 / row3.dot(projPos4);
        return (projInv * projPos4 * cs).xyz;
    }

}
