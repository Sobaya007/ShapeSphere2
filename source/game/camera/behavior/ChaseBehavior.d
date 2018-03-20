module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    mixin DeclareConfig!(float, "CHASE_TARGET_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_CAMERA_Y", "camera.json");
    mixin DeclareConfig!(float, "CHASE_MAX_VELOCITY", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TURN_SPEED", "camera.json");
    mixin DeclareConfig!(float, "CHASE_DEFAULT_LENGTH", "camera.json");
    mixin DeclareConfig!(float, "CHASE_K", "camera.json");
    mixin DeclareConfig!(float, "CHASE_C", "camera.json");
    mixin DeclareConfig!(float, "CHASE_ATTENUATION", "camera.json");
    mixin DeclareConfig!(float, "CHASE_PENETRATION_PENALTY", "camera.json");
    mixin DeclareConfig!(float, "CHASE_RESTITUTION_RATE", "camera.json");

    override void step() {
        target += (player.getCameraTarget - target) * CHASE_TARGET_SPEED_RATE;


        auto radiusConstraint = SoftConstraint(CHASE_K, CHASE_C, 1, 0.02, length(target - camera.pos) - CHASE_DEFAULT_LENGTH, safeNormalize(camera.pos - target), this);
        auto upConstraint    = SoftConstraint(CHASE_K, CHASE_C, 1, 0.02, camera.pos.y - (target.y + CHASE_CAMERA_Y), vec3(0,1,0), this);


        auto colInfos = Array!CollisionInfo(0);
        scope (exit) colInfos.destroy();
        Game.getMap().getStageEntity().collide(colInfos, this.entity);

        auto constraints = Array!HardConstraint(0);
        scope (exit) constraints.destroy();
        foreach (colInfo; colInfos) {
            auto n = colInfo.getPushVector(this.entity);
            auto depth = colInfo.getDepth();
            constraints ~= HardConstraint(CHASE_PENETRATION_PENALTY, CHASE_RESTITUTION_RATE, n, depth, this);
        }

        foreach (i; 0..5) {
            radiusConstraint.solve();
            upConstraint.solve();
            foreach (c; constraints) {
                c.solve();
            }
        }


        vel -= vel * CHASE_ATTENUATION;
        if (vel.length > CHASE_MAX_VELOCITY) {
            vel = CHASE_MAX_VELOCITY * vel.safeNormalize;
        }


        camera.pos += vel;


        camera.lookAt(target);
    }

    override void turn(vec2 value) {
        auto v = this.player.getCameraTarget() - this.camera.pos;
        auto dif = normalize(cross(vec3(0,1,0),v)) * CHASE_TURN_SPEED * value.x;
        vel += dif;
    }

    struct SoftConstraint {
        float distCoef, velCoef, lambdaCoef;
        vec3 dir;
        float dist;
        float lambda;
        float mass;
        ChaseBehavior behavior;

        this(float beta, float gamma, float mass, float step, float dist, vec3 dir, ChaseBehavior behavior) {
            this.mass = mass;
            this.distCoef = -beta / step / (1/mass + gamma);
            this.velCoef = -1 / (1/mass + gamma);
            this.lambdaCoef = -gamma / (1/mass + gamma);
            this.dist = dist;
            this.dir = dir;
            this.lambda = 0;
            this.behavior = behavior;
        }

        void solve() {
            auto dlambda = dot(behavior.vel, dir) * velCoef + dist * distCoef + lambda * lambdaCoef;
            lambda += dlambda;
            
            auto dvel = dlambda / mass;
            behavior.vel += dvel * dir;
        }
    }

    struct HardConstraint {

        vec3 normal;
        float dist;
        float lambda;
        float idealVelocity;
        ChaseBehavior behavior;

        this(float penalty, float restitution, vec3 normal, float dist, ChaseBehavior behavior) {
            this.normal = normal;
            this.dist = dist;
            this.lambda = 0;
            this.behavior = behavior;

            import std.math;
            auto sepVel = (dist-0.01) * penalty;
            auto resVel = fmax(0, -dot(normal, behavior.vel)) * restitution;

            this.idealVelocity = fmax(sepVel, resVel);
        }

        void solve() {
            auto dlambda = idealVelocity - dot(behavior.vel, normal);
            if (dlambda + lambda < 0) return;
            lambda += dlambda;
            behavior.vel += dlambda * normal;
        }
    }
}
