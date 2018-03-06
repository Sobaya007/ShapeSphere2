module sbylib.entity.utils.ColorEntity;

public {
    import sbylib.entity.TypedEntity;
    import sbylib.math.Vector;
}

auto makeColorEntity(
        vec4 color,
        float width,
        float height) {
    import sbylib.geometry.geometry2d.Rect;
    import sbylib.material.ColorMaterial;
    auto entity = makeEntity(Rect.create(width, height), new ColorMaterial(color));
    entity.renderGroupName = "transparent";
    entity.depthWrite = false;
    entity.name = "Color Entity";
    return entity;
}
