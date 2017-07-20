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
        XFrame frame = new XFrame;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "Frame", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        frame.name = tokens.front.lexeme;
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
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
                        assert(false, makeErrorMessage(tokens));
                }
            } else {
                assert(false, makeErrorMessage(tokens));
            }
        }

        return frame;
    }

    XFrameTransformMatrix parseFrameTransformMatrix(DList!XToken tokens) {
        XFrameTransformMatrix frameTransformMatrix = new XFrameTransformMatrix;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "FrameTransformMatrix", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        frameTransformMatrix.matrix = mat4(parseArray!float(tokens, 4*4));

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return frameTransformMatrix;
    }

    XMesh parseMesh(DList!XToken tokens) {
        XMesh mesh = new XMesh;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "Mesh", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int vertexNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        mesh.vertices = parseVecArray!(float, 3)(tokens, vertexNum);

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int faceNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        mesh.faces = new uint[3][](faceNum);
        foreach(i; 0..faceNum) {
            assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
            assert(tokens.front.lexeme == "3", makeErrorMessage(tokens) ~ "\n" ~ "三角ポリゴンになってなさそう(´・ω・`)");
            tokens.removeFront;
            assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            tokens.removeFront;

            mesh.faces[i] = parseArray!uint(tokens, 3);

            if (i == faceNum-1) {
                assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            } else {
                assert(validate!XTokenComma(tokens), makeErrorMessage(tokens));
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
                        assert(false, makeErrorMessage(tokens));
                }
            } else {
                assert(false, makeErrorMessage(tokens));
            }
        }

        return mesh;
    }

    XMeshNormals parseMeshNormals(DList!XToken tokens) {
        XMeshNormals meshNormals = new XMeshNormals;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "MeshNormals", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int normalNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        meshNormals.normals = parseVecArray!(float, 3)(tokens, normalNum);

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int faceNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        meshNormals.indices = new uint[3][](faceNum);
        foreach(i; 0..faceNum) {
            assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
            assert(tokens.front.lexeme == "3", makeErrorMessage(tokens) ~ "\n" ~ "三角ポリゴンになってなさそう(´・ω・`)");
            tokens.removeFront;
            assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            tokens.removeFront;

            meshNormals.indices[i] = parseArray!uint(tokens, 3);

            if (i == faceNum-1) {
                assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            } else {
                assert(validate!XTokenComma(tokens), makeErrorMessage(tokens));
            }
            tokens.removeFront;
        }

        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return meshNormals;
    }

    XMeshTextureCoords parseMeshTextureCoords(DList!XToken tokens) {
        XMeshTextureCoords meshTextureCoords = new XMeshTextureCoords;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "MeshTextureCoords", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int uvNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        meshTextureCoords.uvArray = parseVecArray!(float, 2)(tokens, uvNum);

        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return meshTextureCoords;
    }

    XMeshMaterialList parseMeshMaterialList(DList!XToken tokens) {
        XMeshMaterialList meshMaterialList = new XMeshMaterialList;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "MeshMaterialList", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int materialNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        int indexNum = tokens.front.lexeme.to!int;
        tokens.removeFront;

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        meshMaterialList.indices = parseArray!uint(tokens, indexNum);

        meshMaterialList.materials = new XMaterial[materialNum];
        foreach(i; 0..materialNum) {
            meshMaterialList.materials[i] = parseMaterial(tokens);
        }

        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return meshMaterialList;
    }

    XMaterial parseMaterial(DList!XToken tokens) {
        XMaterial material = new XMaterial;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "Material", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        material.name = tokens.front.lexeme;
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        material.faceColor = parseVecArray!(float, 4)(tokens, 1).front;
        material.power = parseArray!float(tokens, 1).front;
        material.specularColor = parseVecArray!(float, 3)(tokens, 1).front;
        material.emissiveColor = parseVecArray!(float, 3)(tokens, 1).front;

        if (validate!XTokenLabel(tokens) && tokens.front.lexeme == "TextureFilename") {
            material.textureFileName = parseTextureFilename(tokens);
        }


        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return material;
    }

    XTextureFilename parseTextureFilename(DList!XToken tokens) {
        XTextureFilename textureFileName = new XTextureFilename;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        assert(tokens.front.lexeme == "TextureFilename", makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLeftParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenLabel(tokens), makeErrorMessage(tokens));
        string lexeme = tokens.front.lexeme;
        assert(lexeme.length > 2, makeErrorMessage(tokens));
        assert(lexeme.front == '"', makeErrorMessage(tokens));
        assert(lexeme.back == '"', makeErrorMessage(tokens));
        textureFileName.name = lexeme[1..$-1];

        assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        assert(validate!XTokenRightParen(tokens), makeErrorMessage(tokens));
        tokens.removeFront;

        return textureFileName;
    }

    T[] parseArray(T)(DList!XToken tokens, int num) {
        T[] result = new T[num];
        foreach(i; 0..num) {
            result[i] = tokens.front.lexeme.to!T;
            tokens.removeFront;
            if (i == num-1) {
                assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            } else {
                assert(validate!XTokenComma(tokens), makeErrorMessage(tokens));
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
                assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
                tokens.removeFront;
            }
            result[i] = Vector!(T, S)(elements);
            if (i == num-1) {
                assert(validate!XTokenSemicolon(tokens), makeErrorMessage(tokens));
            } else {
                assert(validate!XTokenComma(tokens), makeErrorMessage(tokens));
            }
            tokens.removeFront;
        }
        return result;
    }

    // tokensの先頭がTにキャストできるか？
    bool validate(T)(DList!XToken tokens) {
        return !tokens.empty && cast(T)tokens.front;
    }

    string makeErrorMessage(DList!XToken tokens) {
        import std.format;
        if (tokens.empty) {
            return "XFileParseError";
        } else {
            return "XFileParseError" ~ format("(line: %s, column: %s, lexeme: \"%s\")", tokens.front.line, tokens.front.column, tokens.front.lexeme);
        }
    }

}
