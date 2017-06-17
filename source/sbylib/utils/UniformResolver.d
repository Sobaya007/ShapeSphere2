module sbylib.utils.UniformResolver;

import sbylib.material.glsl.Constants;
import sbylib.core.World;

class UniformResolver {

    private this() {}

    public static void resolve(World world) {
        foreach (mesh; world.meshes) {
            foreach (dem; mesh.mat.demands) {
                final switch (dem) {
                case UniformDemand.World:
                    mesh.mat.addUniform(mesh.obj.worldMatrix);
                    break;
                case UniformDemand.View:
                    mesh.mat.addUniform(world.viewMatrix);
                    break;
                case UniformDemand.Proj:
                    mesh.mat.addUniform(world.projMatrix);
                    break;
                }
            }
            mesh.mat.demands = [];
        }
    }
}
