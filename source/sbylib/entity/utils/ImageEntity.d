module sbylib.entity.utils.ImageEntity;

public {
    import sbylib.entity.Entity;
    import sbylib.utils.Path;
    import sbylib.wrapper.freeimage.Image;
    import sbylib.wrapper.gl.Texture;
}
import sbylib.utils.Functions;

auto makeImageEntity(
        ImagePath path,
        float width,
        float height) {
    import sbylib.wrapper.freeimage.ImageLoader;
    return makeImageEntity(ImageLoader.load(path), width, height);
}

auto makeImageEntity(
        Image img,
        float width,
        float height) {
    return makeImageEntity(
        generateTexture(img),
        width,
        height
    );
}

auto makeImageEntity(
        Texture texture,
        float width,
        float height) {
    import sbylib.material.TextureMaterial;
    import sbylib.geometry.geometry2d.Rect;
    return makeEntity(
        Rect.create(width, height),
        new TextureMaterial(texture)
    );
}
