module game.GameMain;

import sbylib;
import game.scene;

void gameMain(string[] args) {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);

    screen.setClearColor(vec4(0.2));

    core.addProcess({
        if (core.getKey[KeyButton.Escape]) {
            core.end();
        }
    }, "po");

    core.addProcess(&AnimationManager().step, "Animation Manager");

    setGameTransition(args);

    core.start();
}

void setGameTransition(string[] args) {
    GameMainScene.args = args;
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
