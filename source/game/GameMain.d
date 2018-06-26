module game.GameMain;

import sbylib;
import game.scene;
import game.Game;

void gameMain(string[] args) {

    setGameTransition(args);

    Core().start();
}

void setGameTransition(string[] args) {
    Game.initialize(args);
    with (SceneManager) {
        define(
            GameMainScene(
                onFinish(
                    move!Title
                )
            ),
        );
        launch!(GameMainScene);
    }
}
