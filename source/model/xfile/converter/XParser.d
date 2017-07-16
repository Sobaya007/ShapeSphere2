module model.xfile.converter.XParser;

import sbylib.math.Vector;
import sbylib.math.Matrix;

import model.xfile.converter.XConverter;
import model.xfile.XToken;
import model.xfile.node;

import std.conv,
       std.range,
       std.algorithm,
       std.container : DList;

// XParser: DList!XToken -> XFrame

class XParser : XConverter!(DList!XToken, XFrame) {
    override XFrame run(DList!XToken src) {
        return parse(src);
    }

private:

    XFrame parse(DList!XToken tokens) {
        XFrame frame = parseFrame(tokens);
        assert(tokens.empty);
        return frame;
    }

    XFrame parseFrame(DList!XToken tokens) {
        XFrame frame;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "Frame");
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        frame.name = tokens.front.lexeme;
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        while(true) {
            if (validate!XTokenRightParen(tokens)) {
                tokens.removeFront;
                break;
            } else if (validate!XTokenLabel(tokens)) {
                switch(tokens.front.lexeme) {
                    case "FrameTransformMatrix":
                        frame.frameTransformMatrix = parseFrameTransformMatrix(tokens);
                        break;
                    case "Frame":
                        frame.frames ~= parseFrame(tokens);
                        break;
                    case "Mesh":
                        frame.meshes ~= parseMesh(tokens);
                        break;
                    default:
                        assert(false);
                }
            } else {
                assert(false);
            }
        }

        return frame;
    }

    XFrameTransformMatrix parseFrameTransformMatrix(DList!XToken tokens) {
        XFrameTransformMatrix frameTransformMatrix;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "FrameTransformMatrix");
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        frameTransformMatrix.matrix = mat4(parseArray!float(tokens, 4*4));

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return frameTransformMatrix;
    }

    XMesh parseMesh(DList!XToken tokens) {
        XMesh mesh;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "Mesh");
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        int vertexNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        mesh.vertices = parseVecArray!(float, 3)(tokens, vertexNum);

        assert(validate!XTokenLabel(tokens));
        int faceNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        mesh.faces = new uint[3][](faceNum);
        foreach(i; 0..faceNum) {
            assert(validate!XTokenLabel(tokens));
            assert(tokens.front.lexeme == "3", "三角ポリゴンになってなさそう(´・ω・`)");
            tokens.removeFront;
            assert(validate!XTokenSemicolon(tokens));
            tokens.removeFront;

            mesh.faces[i] = parseArray!uint(tokens, 3);

            if (i == faceNum-1) {
                assert(validate!XTokenSemicolon(tokens));
            } else {
                assert(validate!XTokenComma(tokens));
            }
            tokens.removeFront;
        }

        while(true) {
            if (validate!XTokenRightParen(tokens)) {
                tokens.removeFront;
                break;
            } else if (validate!XTokenLabel(tokens)) {
                switch(tokens.front.lexeme) {
                    case "MeshNormals":
                        mesh.meshNormals = parseMeshNormals(tokens);
                        break;
                    case "MeshTextureCoords":
                        mesh.meshTextureCoords = parseMeshTextureCoords(tokens);
                        break;
                    case "MeshMaterialList":
                        mesh.meshMaterialList = parseMeshMaterialList(tokens);
                        break;
                    default:
                        assert(false);
                }
            } else {
                assert(false);
            }
        }

        return mesh;
    }

    XMeshNormals parseMeshNormals(DList!XToken tokens) {
        XMeshNormals meshNormals;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "MeshNormals");
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        int normalNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        meshNormals.normals = parseVecArray!(float, 3)(tokens, normalNum);

        assert(validate!XTokenLabel(tokens));
        int faceNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        meshNormals.indices = new uint[3][](faceNum);
        foreach(i; 0..faceNum) {
            assert(validate!XTokenLabel(tokens));
            assert(tokens.front.lexeme == "3", "三角ポリゴンになってなさそう(´・ω・`)");
            tokens.removeFront;
            assert(validate!XTokenSemicolon(tokens));
            tokens.removeFront;

            meshNormals.indices[i] = parseArray!uint(tokens, 3);

            if (i == faceNum-1) {
                assert(validate!XTokenSemicolon(tokens));
            } else {
                assert(validate!XTokenComma(tokens));
            }
            tokens.removeFront;
        }

        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return meshNormals;
    }

    XMeshTextureCoords parseMeshTextureCoords(DList!XToken tokens) {
        XMeshTextureCoords meshTextureCoords;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "MeshTextureCoords");
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        int uvNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        meshTextureCoords.uvArray = parseVecArray!(float, 2)(tokens, uvNum);

        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return meshTextureCoords;
    }

    XMeshMaterialList parseMeshMaterialList(DList!XToken tokens) {
        XMeshMaterialList meshMaterialList;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "MeshMaterialList");
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        int materialNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        int indexNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        meshMaterialList.indices = parseArray!uint(tokens, indexNum);

        meshMaterialList.materials = new XMaterial[materialNum];
        foreach(i; 0..materialNum) {
            meshMaterialList.materials[i] = parseMaterial(tokens);
        }

        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return meshMaterialList;
    }

    XMaterial parseMaterial(DList!XToken tokens) {
        XMaterial material;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "Material");
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        material.name = tokens.front.lexeme;
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        material.faceColor = parseVecArray!(float, 4)(tokens, 1).front;
        material.power = parseArray!float(tokens, 1).front;
        material.specularColor = parseVecArray!(float, 3)(tokens, 1).front;
        material.emissiveColor = parseVecArray!(float, 3)(tokens, 1).front;

        if (validate!XTokenLabel(tokens) && tokens.front.lexeme == "TextureFilename") {
            material.textureFileName = parseTextureFilename(tokens);
        }


        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return material;
    }

    XTextureFilename parseTextureFilename(DList!XToken tokens) {
        XTextureFilename textureFileName;

        assert(validate!XTokenLabel(tokens));
        assert(tokens.front.lexeme == "TextureFilename");
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens));
        string lexeme = tokens.front.lexeme;
        assert(lexeme.length > 2);
        assert(lexeme.front == '"');
        assert(lexeme.back == '"');
        textureFileName.name = lexeme[1..$-1];

        assert(validate!XTokenSemicolon(tokens));
        tokens.removeFront;

        assert(validate!XTokenRightParen(tokens));
        tokens.removeFront;

        return textureFileName;
    }

    T[] parseArray(T)(DList!XToken tokens, int num) {
        T[] result = new T[num];
        foreach(i; 0..num) {
            result[i] = tokens.front.lexeme.to!T;
            tokens.removeFront;
            if (i == num-1) {
                assert(validate!XTokenSemicolon(tokens));
            } else {
                assert(validate!XTokenComma(tokens));
            }
            tokens.removeFront;
        }
        return result;
    }

    Vector!(T, S)[] parseVecArray(T, uint S)(DList!XToken tokens, int num) {
        Vector!(T, S)[] result = new Vector!(T, S)[num];
        foreach(i; 0..num) {
            T[] elements = new T[S];
            foreach(j; 0..S) {
                elements[j] = tokens.front.lexeme.to!T;
                tokens.removeFront;
                assert(validate!XTokenSemicolon(tokens));
                tokens.removeFront;
            }
            result[i] = Vector!(T, S)(elements);
            if (i == num-1) {
                assert(validate!XTokenSemicolon(tokens));
            } else {
                assert(validate!XTokenComma(tokens));
            }
            tokens.removeFront;
        }
        return result;
    }

    // tokensの先頭がTにキャストできるか？
    bool validate(T)(DList!XToken tokens) {
        return !tokens.empty && cast(T)tokens.front;
    }

}

unittest {
    // import std.stdio, std.file, sbylib.setting;
    //
    //
    // string src = readText(RESOURCE_ROOT ~ "model/bbbb.x");
    //
    // import model.xfile.converter.XLexer;
    // XLexer lexer = new XLexer;
    // XParser parser = new XParser;
    //
    // auto tokens = lexer.run(src);
    //
    // XFrame frame = parser.run(tokens);
    //
    // frame.writeln;
}
