module sbylib.utils.Loader;

import std.typecons;
import sbylib.utils.Path;
import sbylib.utils.Functions;

class ImageLoader {
    import FreeImage = sbylib.wrapper.freeimage.ImageLoader;
    import sbylib.wrapper.freeimage.Image;
static:
    private FreeImage.Image[string] cache;

    Image load(string path, bool useCache=true, bool writeCache=true) {
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

class XLoader {
    import sbylib.model.xfile.loader.XLoader : OriginalLoader = XLoader;
    import sbylib.model.xfile.loader.XEntity;
    import std.typecons;

    mixin Singleton;
static:
    private Rebindable!(immutable(XEntity))[ModelPath] cache;

    immutable(XEntity) load(ModelPath path, bool materialRequired=true, bool normalRequired=true, bool uvRequred=true, bool useCache=true, bool writeCache=true) {
        if (useCache) {
            if (auto r = path in cache) return *r;
        }
        auto result = OriginalLoader().load(path, materialRequired, normalRequired, uvRequred);
        if (writeCache) {
            cache[path] = result;
        }
        return result;
    }
}
