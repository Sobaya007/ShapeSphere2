module game.tool.manipulator.ManipulatorManager;

import sbylib;
import game.Game;
import game.tool.manipulator;

class ManipulatorManager {

private:
    Manipulator manipulator;

public:
    this() {
        this.manipulator = new Manipulator();
        Game.getWorld3D.add(this.manipulator.entity);
    }
}
