module plot.circle.Circle;

import sbylib;
import plot.circle.CircleMaterial;

class Circle {
    Entity entity;

    this(float radius, vec3 color) {
        auto rect = Rect.create(radius*2, radius*2);
        auto mat = new CircleMaterial;
        mat.color = color;
        this.entity = new Entity(rect, mat);
    }
}
