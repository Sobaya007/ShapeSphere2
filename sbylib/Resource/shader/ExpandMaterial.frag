uniform bool expand;

require Shader OriginalMaterial;
require Shader ExpandedRegionMaterial;

void main() {
    if (expand) {
        ExpandedRegionMaterial(fragColor);
    } else {
        OriginalMaterial(fragColor);
    }
}
