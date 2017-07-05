module sbylib.character.Letter;

import sbylib.wrapper.freetype.LetterInfo;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.mesh.Mesh;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;

class Letter {

    alias LetterMesh = MeshTemp!(GeometryRect, TextMaterial);

    private LetterMesh mesh;
    private LetterInfo info;

    this(Font font, dchar c, float height) {
        font.loadChar(c, FontLoadType.Render);
        this.info = font.characters[c];
        auto geom = Rect.create(height * this.info.width / this.info.height, height);
        this.mesh = new LetterMesh(geom);
        this.mesh.mat.texture = this.info.texture;
        this.mesh.mat.color = vec4(0,0,0,1);
    }

    LetterMesh getMesh() {
        return this.mesh;
    }

    LetterInfo getInfo() {
        return this.info;
    }
}
