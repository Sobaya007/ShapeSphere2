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
    XEntity load(ModelPath path, bool materialRequired = true, bool normalRequired = true, bool uvRequired = true) {
        this.materialRequired = materialRequired;
        this.normalRequired   = normalRequired;
        this.uvRequired       = uvRequired;

        string src = readText(path);
        XFrameNode root = this.parser.run(this.lexer.run(src));
        return makeEntity(root, mat4.identity);
    }

private:
    XEntity makeEntity(XFrameNode parent, mat4 transformMat) {
        XEntity entity = new XEntity;

        mat4 mat = transformMat * mat4.transpose(parent.frameTransformMatrix.matrix);

        if (parent.mesh !is null) {
            entity.children ~= makeEntity(parent.mesh, mat);
        }
        foreach(xFrame; parent.frames) {
            entity.children ~= makeEntity(xFrame, mat);
        }

        return entity;
    }

    XEntity makeEntity(XMeshNode xMesh, mat4 transformMat) {
        XEntity entity = new XEntity;
        entity.geometry = new XGeometry;

        vec3[] vertices = xMesh.vertices.map!(
            v => transformMat * vec4(v, 1.0)
        ).map!(
            v => v.xyz
        ).array;
        uint[][] faceIndices = xMesh.faces.to!(uint[][]);

        entity.geometry.positions = faceIndices.join.map!(
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

        entity.geometry.normals = normalIndices.join.map!(
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
            entity.geometry.uvs = faceIndices.join.map!(
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
        XMaterial[] materials;
        uint[] materialIndices;
        if (xMesh.meshMaterialList !is null) {
            materials = xMesh.meshMaterialList.materials.map!(m => makeMaterial(m)).array;
            materialIndices = xMesh.meshMaterialList.indices;
        }

        entity.leviathans = new XLeviathan[materials.length];
        foreach(i; 0..materials.length) {
            entity.leviathans[i] = new XLeviathan;
            entity.leviathans[i].material = materials[i];
            entity.leviathans[i].indices = materialIndices.enumerate.filter!(
                a => a.value == i
            ).map!"cast(uint)a.index".map!(
                j => iota(3*j, 3*(j+1))
            ).join.array;
        }

        return entity;
    }

    XMaterial makeMaterial(XMaterialNode xMaterialNode) {
        XMaterial material = new XMaterial;

        material.diffuse = xMaterialNode.faceColor;
        material.specular = xMaterialNode.specularColor;
        material.ambient = xMaterialNode.emissiveColor;
        material.power = xMaterialNode.power;

        if (xMaterialNode.textureFileName !is null) {
            material.setTectureFileName(xMaterialNode.textureFileName.name);
        }

        return material;
    }


}
