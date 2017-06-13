module sbylib.material.UniformResolver;

import sbylib.material.Constants;
import sbylib.core.World;

class UniformResolver {

    private this() {}

    void resolve(World world) {
        foreach (mesh; world.meshes) {
            foreach (dem; mesh.mat.getDemands()) {
                final switch (dem) {
                case UniformDemand.WorldMatrix:
                    mesh.mat.addUniform(dem, mesh.obj.worldMatrix);
                    break;
                case UniformDemand.ViewMatrix:
                    mesh.mat.addUniform(dem, world.viewMatrix);
                    break;
                case UniformDemand.ProjMatrix:
                    mesh.mat.addUniform(dem, world.projMatrix);
                    break;
                }
            }
        }
    }
}
