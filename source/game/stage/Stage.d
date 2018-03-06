module game.stage.Stage;

import sbylib;

interface Stage {

    Entity getStageEntity();
    Entity getCharacterEntity();
    Entity getMoveEntity();
    void transit(string);
    void pause();
    void resume();

}
