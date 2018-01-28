module sbylib.utils.Loader;

import std.typecons;
import sbylib.utils.Path;

class ImageLoader {
    import FreeImage = sbylib.wrapper.freeimage.ImageLoader;
    import sbylib.wrapper.freeimage.Image;
static:
    private FreeImage.Image[ImagePath] cache;

    Image load(ImagePath path, bool useCache=true, bool writeCache=true) {
        if (useCache) {
            if (auto r = path in cache) return *r;
        }
        auto result = FreeImage.ImageLoader.load(path);
        if (writeCache) {
            cache[path] = result;
        }
        return result;
    }
}

class FontLoader {
    import FreeType = sbylib.wrapper.freetype.FontLoader;
    import sbylib.wrapper.freetype.Font;
static:
    private FreeType.Font[Tuple!(FontPath, uint)] cache;

    Font load(FontPath path, uint size, bool useCache=true, bool writeCache=true) {
        if (useCache) {
            if (auto r = tuple(path, size) in cache) return *r;
        }
        auto result = FreeType.FontLoader.load(path, size);
        if (writeCache) {
            cache[tuple(path, size)] = result;
        }
        return result;
    }
}
