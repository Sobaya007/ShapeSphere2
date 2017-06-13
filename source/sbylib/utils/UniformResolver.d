module sbylib.utils.UniformResolver;

import sbylib.material.Constants;
import sbylib.core.World;

class UniformResolver {

    private this() {}

    public static void resolve(World world) {
        foreach (mesh; world.meshes) {
            foreach (dem; mesh.mat.demands) {
                final switch (dem) {
                case UniformDemand.WorldMatrix:
                    mesh.mat.addUniform(mesh.obj.worldMatrix);
                    break;
                case UniformDemand.ViewMatrix:
                    mesh.mat.addUniform(world.viewMatrix);
                    break;
                case UniformDemand.ProjMatrix:
                    mesh.mat.addUniform(world.projMatrix);
                    break;
                }
            }
            mesh.mat.demands = [];
        }
    }
}
