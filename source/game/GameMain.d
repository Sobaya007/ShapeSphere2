module game.GameMain;

import sbylib;
import game.scene;
import game.Game;

void gameMain(string[] args) {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);

    screen.setClearColor(vec4(0.2));

    core.addProcess(&AnimationManager().step, "Animation Manager");

    setGameTransition(args);

    core.start();
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
