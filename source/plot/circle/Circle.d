module plot.circle.Circle;

import sbylib;
import plot.circle.CircleMaterial;

class Circle {
    Mesh mesh;

    this(float radius, vec3 color) {
        auto rect = Rect.create(radius*2, radius*2);
        auto mat = new CircleMaterial;
        mat.color = color;
        this.mesh = new Mesh(rect, mat);
    }
}
