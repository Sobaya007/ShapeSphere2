module sbylib.entity.ColorEntity;

import sbylib.entity.Entity;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.ColorMaterial;
import sbylib.math.Vector;

EntityTemp!(GeometryRect, ColorMaterial) ColorEntity(
        vec4 color,
        float width,
        float height) {
    auto geom = Rect.create(width, height);
    auto mat = new ColorMaterial;
    mat.color = color;
    mat.config.transparency = true;
    mat.config.depthWrite = false;
    auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom, mat);

    return entity;
}
