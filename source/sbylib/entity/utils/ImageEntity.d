module sbylib.entity.utils.ImageEntity;

public {
    import sbylib.entity.Entity;
}
import sbylib.wrapper.freeimage.ImageLoader;
import sbylib.material.TextureMaterial;
import sbylib.geometry.geometry2d.Rect;
import sbylib.utils.Path;
import sbylib.utils.Functions;

auto ImageEntity(
        ImagePath path,
        float width,
        float height) {
    return makeEntity(
        Rect.create(width, height),
        new TextureMaterial(Utils.generateTexture(ImageLoader.load(path)))
    );
}
