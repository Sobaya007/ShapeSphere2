module examples.SceneExample;

import sbylib;
import std.algorithm, std.array;
import std.math;
import game.scene;

void sceneExample() {
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

    setGameTransition();

    core.start();
}

void setGameTransition() {
    //アニメーション情報をどこまで詳細に載せるか
    //具体的に見えるものは後。
    //とりあえず遷移図を記す。
    with (SceneManager) {
        define(
            LogoAnimation(
                onFinish(
                    move!OpeningAnimation
                )
            ),
            OpeningAnimation(
                onFinish(
                    move!Title
                )
             ),
            Title(
                onStable( //落ちつくってなに
                    over!(Select!(
                        NewGame,
                        LoadGame,
                        Exit
                    ))
                )
            ),
            NewGame(
                onYes(
                    move!OpeningMovie(
                        onFinish(
                            move!OpeningStage(
                                onFinish(
                                    move!Stage //現在の状態をみていいかんじのステージに飛ぶ
                                )
                            )
                        )
                    )
                ),
                onNo(
                    pop
                )
            ),
            LoadGame(
                onYes(
                    move!Stage
                ),
                onNo(
                    pop
                )
            ),
            Exit(
                onNo(
                    pop
                )
            ),
        );
        launch!(LogoAnimation);
    }
}
