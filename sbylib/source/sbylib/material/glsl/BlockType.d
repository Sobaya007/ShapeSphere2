module sbylib.material.glsl.BlockType;

enum BlockType {
    Struct,
    Uniform
}

string getBlockTypeCode(BlockType b) {
    final switch(b) {
    case BlockType.Struct:
        return "struct";
    case BlockType.Uniform:
        return "uniform";
    }
}
