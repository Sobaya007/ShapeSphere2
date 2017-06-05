module sbylib.entity.CameraChaser;
import sbylib;

class CameraChaser {


protected :
    Primitive target;
    Primitive focus;
    Camera camera;
    vec3 toCamera;
    float defaultDistance;
    float defaultY;
    vec3 spd = vec3(0,0,0);

    immutable k = 0.003;
    immutable c = 0.05;
public:

    this(Camera camera, Primitive focus) {
        this.camera = camera;
        this.focus = focus;
        toCamera = camera.Position - focus.Position;
        defaultDistance = toCamera.xz.length;
        defaultY = toCamera.y;
    }

    bool step() {

        with(camera) {
            auto d = Position - focus.Position;
            d.y = 0;
            auto len = d.length;
            d /= len;

            len -= defaultDistance;
            d *= len;
            spd -= d * k + spd * c;
            Position = Position + spd;
            Position = vec3(Position.x, focus.Position.y + defaultY, Position.z);

            vecZ = (Position - focus.Position).normalize;
            vecX = cross(vec3(0,1,0), getVecZ).normalize;
            vecY = cross(getVecZ, getVecX).normalize;

            if (Input.pressed(KeyButton.W)) {
                defaultDistance -= .1;
            }
            if (Input.pressed(KeyButton.S)) {
                defaultDistance += .1;
            }

            auto omega = .1145141919810 / 4 * Input.joySticks[0].getAxis(JoyStick.Axis.RightX);
            auto v = SbyWorld.currentCamera.Position - focus.Position;
            auto rot = mat4.rotAxisAngle(vec3(0,1,0), omega);
            v = (rot * vec4(v, 1)).xyz;
            with (SbyWorld.currentCamera) {
                Position = focus.Position + v;
                vecX = (rot * vec4(getVecX, 0)).xyz;
                vecY = (rot * vec4(getVecY, 0)).xyz;
                vecZ = (rot * vec4(getVecZ, 0)).xyz;
            }

            static vec2 beforeMousepos;
            vec2 mousepos = Input.mousePos;
            if (Input.pressed(MouseButton.Button1)) {
                const float delta = 0.005;
                auto mat = mat4.translate(focus.Position) * mat4.rotFromTo(getVecZ, normalize(getVecZ
                             - getVecX * (delta * (mousepos.x - beforeMousepos.x))
                             + getVecY * (delta * (mousepos.y - beforeMousepos.y)))) * mat4.translate(-focus.Position);
                Position = (mat * vec4(Position, 1)).xyz;
                vecZ = (mat * vec4(getVecZ, 1)).xyz;
                defaultY = Position.y - focus.Position.y;
            }
            vecZ = normalize(Position - focus.Position);
            vecX = normalize(cross(getVecY, getVecZ));
            vecY = cross(getVecZ, getVecX).normalize;
            beforeMousepos = mousepos;
        }

        return true;
    }

    override string toString() {
        return "CameraChaser";
    }
}
