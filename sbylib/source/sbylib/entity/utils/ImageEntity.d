module sbylib.entity.utils.ImageEntity;

public {
    import sbylib.entity.TypedEntity;
    import sbylib.utils.Path;
    import sbylib.wrapper.freeimage.Image;
    import sbylib.wrapper.gl.Texture;
    import sbylib.material.TextureMaterial;
    import sbylib.geometry.geometry2d.Rect;
}
import sbylib.utils.Functions;

struct ImageEntityFactory {
    private Maybe!float mWidth, mHeight;

    void width(float w) {
        this.mWidth = Just(w);
    }
    
    void height(float h) {
        this.mHeight = Just(h);
    }

    auto make(ImagePath path) {
        import sbylib.utils.Loader;
        return make(ImageLoader.load(path));
    }

    auto make(Image image)
        in(this.mWidth.isJust || this.mHeight.isJust, "'width' or 'height' must be assigned")
    {
        auto texture = generateTexture(image);
        if (this.mWidth.isJust && this.mHeight.isJust)
            return make(texture, this.mWidth.unwrap(), this.mHeight.unwrap());
        else if (this.mWidth.isJust)
            return make(texture, this.mWidth.unwrap(), this.mWidth.unwrap() * image.getHeight() / image.getWidth());
        else
            return make(texture, this.mHeight.unwrap() * image.getWidth() / image.getHeight(), this.mHeight.unwrap());
    }

    auto make(Texture texture)
        in(this.mWidth.isJust, "'width' must be assigned")
        in(this.mHeight.isJust, "'height' must be assigned")
    {
        return make(texture, this.mWidth.unwrap(), this.mHeight.unwrap());
    }

    private auto make(Texture texture, float w, float h) {
        return makeEntity(
            Rect.create(w, h),
            new TextureMaterial(texture)
        );
    }
}

alias ImageEntity = TypedEntity!(GeometryRect, TextureMaterial);
