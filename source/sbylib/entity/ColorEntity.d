module sbylib.entity.ColorEntity;

import sbylib.entity.Entity;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.ColorMaterial;
import sbylib.math.Vector;

EntityTemp!(GeometryRect, ColorMaterial) ColorEntity(
        float width,
        float height) {
    auto geom = Rect.create(width, height);
    auto mat = new ColorMaterial;
    auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom, mat);

    mat.color = vec4(1);

    return entity;
}
