module model.xfile.loader.XLoader;

import sbylib;
import model.xfile.node;
import model.xfile.converter;
import model.xfile.loader;

import std.range, std.array, std.algorithm;

import std.file, std.conv, std.format;

/*
Xファイルのモデルデータを読み込むよ。

読み込むデータ
- 位置
- 法線
- UV座標
- インデックス
- テクスチャのパス
- faceColor/power/specularColor/emissiveColor
*/


class XLoader {

private:
    XLexer lexer   = new XLexer;
    XParser parser = new XParser;

    bool materialRequired;
    bool normalRequired;
    bool uvRequired;

public:

    /*
        path             ... xファイルのパス
        materialRequired ... trueなら、マテリアル情報がないときにassertion
        normalRequired   ... trueなら、法線情報がないときにassertion
        uvRequired       ... trueなら、UV座標の情報がないときにassertion
    */
    immutable(XEntity) load(ModelPath path, bool materialRequired = true, bool normalRequired = true, bool uvRequired = true) {
        this.materialRequired = materialRequired;
        this.normalRequired   = normalRequired;
        this.uvRequired       = uvRequired;

        string src = readText(path);
        XFrameNode root = this.parser.run(this.lexer.run(src));
        return makeEntity(root, mat4.identity);
    }

private:
    import std.stdio;
    immutable(XEntity) makeEntity(XFrameNode parent, mat4 transformMat) {
        writeln("make Entity");
        mat4 mat = transformMat * mat4.transpose(parent.frameTransformMatrix.matrix);

        immutable(XEntity)[] children;
        if (parent.mesh !is null) {
            children ~= makeEntity(parent.mesh, mat);
        }
        foreach(xFrame; parent.frames) {
            children ~= makeEntity(xFrame, mat);
        }

        return new immutable(XEntity)(children);
    }

    immutable(XEntity) makeEntity(XMeshNode xMesh, mat4 transformMat) {
        writeln("make Entity(mesh)");
        struct Geom {
            vec3[] positions;
            vec3[] normals;
            vec2[] uvs;
        }
        Geom geom;

        vec3[] vertices = xMesh.vertices.map!(
            v => transformMat * vec4(v, 1.0)
        ).map!(
            v => v.xyz
        ).array;
        uint[][] faceIndices = xMesh.faces.to!(uint[][]);

        geom.positions = faceIndices.join.map!(
            i => vertices[i]
        ).array;

        if (this.normalRequired) {
            assert(
                xMesh.meshNormals !is null,
                format(
                    "(line: %s, column: %s, lexeme: \"%s\"): 法線情報がないよ",
                    xMesh.headToken.line, xMesh.headToken.column, xMesh.headToken.lexeme
                )
            );
        }
        vec3[] normals;
        uint[][] normalIndices;
        if (xMesh.meshNormals !is null) {
            normals = xMesh.meshNormals.normals.map!(
                n => transformMat * vec4(n, 0.0)
            ).map!(
                n => n.xyz
            ).array;
            normalIndices = xMesh.meshNormals.indices.to!(uint[][]); // 3*面の数
        }

        geom.normals = normalIndices.join.map!(
            i => normals[i]
        ).array;

        if (this.uvRequired) {
            assert(
                xMesh.meshTextureCoords !is null,
                format(
                    "(line: %s, column: %s, lexeme: \"%s\"): UV情報がないよ",
                    xMesh.headToken.line, xMesh.headToken.column, xMesh.headToken.lexeme
                )
            );
        }
        if (xMesh.meshTextureCoords !is null) {
            vec2[] uvs = xMesh.meshTextureCoords.uvs;
            assert(uvs.length == vertices.length, "頂点の個数とUV情報の個数が合わないよ");
            geom.uvs = faceIndices.join.map!(
                i => uvs[i]
            ).array;
        }

        if (this.materialRequired) {
            assert(
                xMesh.meshMaterialList !is null,
                format(
                    "(line: %s, column: %s, lexeme: \"%s\"): マテリアル情報がないよ",
                    xMesh.headToken.line, xMesh.headToken.column, xMesh.headToken.lexeme
                )
            );
        }
        immutable(XMaterial)[] materials;
        uint[] materialIndices;
        if (xMesh.meshMaterialList !is null) {
            materials = xMesh.meshMaterialList.materials.map!(m => makeMaterial(m)).array;
            materialIndices = xMesh.meshMaterialList.indices;
        }

        immutable(XLeviathan)[] leviathans;
        foreach(i; 0..materials.length) {
            leviathans ~= new immutable(XLeviathan)(
                materials[i],
                materialIndices.enumerate.filter!(
                    a => a.value == i
                ).map!"cast(uint)a.index".map!(
                    j => iota(3*j, 3*(j+1))
                ).join.array.idup
            );
        }

        return new immutable(XEntity)(new immutable(XGeometry)(geom.positions.idup, geom.normals.idup, geom.uvs.idup), leviathans);
    }

    immutable(XMaterial) makeMaterial(XMaterialNode xMaterialNode) {
        XMaterial material;

        if (xMaterialNode.textureFileName !is null) {
            return new immutable(XMaterial)(xMaterialNode.faceColor, xMaterialNode.specularColor, xMaterialNode.emissiveColor, xMaterialNode.power, xMaterialNode.name, xMaterialNode.textureFileName.name);
        } else {
            return new immutable(XMaterial)(xMaterialNode.faceColor, xMaterialNode.specularColor, xMaterialNode.emissiveColor, xMaterialNode.power, xMaterialNode.name);
        }
    }


}
