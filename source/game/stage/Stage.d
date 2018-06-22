module game.stage.Stage;

import sbylib;

interface Stage {

    Entity mapEntity();
    Entity otherEntity();
    Entity characterEntity();
    Entity moveEntity();
    void transit(string);
    void pause();
    void resume();
    void save();
    void render();
}
