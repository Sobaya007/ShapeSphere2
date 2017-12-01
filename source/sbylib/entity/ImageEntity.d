module sbylib.entity.ImageEntity;

public {
    import sbylib.entity.Entity;
}
import sbylib.wrapper.freeimage.ImageLoader;
import sbylib.material.TextureMaterial;
import sbylib.geometry.geometry2d.Rect;
import sbylib.utils.Path;
import sbylib.utils.Functions;

Entity ImageEntity(
        ImagePath path,
        float width,
        float height) {
    auto image = Utils.generateTexture(ImageLoader.load(path));
    auto geom = Rect.create(width, height);
    auto mat = new TextureMaterial;
    auto entity = new Entity(geom, mat);

    mat.texture = image;

    //mat.config.depthWrite = false;

    return entity;
}
