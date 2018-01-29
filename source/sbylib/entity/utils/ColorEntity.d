module sbylib.entity.utils.ColorEntity;

import sbylib.entity.Entity;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.ColorMaterial;
import sbylib.math.Vector;

auto ColorEntity(
        vec4 color,
        float width,
        float height) {
    auto entity = makeEntity(Rect.create(width, height), new ColorMaterial(color));
    entity.transparency = true;
    entity.depthWrite = false;
    return entity;
}
