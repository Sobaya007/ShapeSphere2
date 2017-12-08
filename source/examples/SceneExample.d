module examples.SceneExample;

import sbylib;
import std.algorithm, std.array;
import std.math;
import game.scene;

void sceneExample(string[] args) {
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
    //アニメーション情報をどこまで詳細に載せるか
    //具体的に見えるものは後。
    //とりあえず遷移図を記す。
    import std.traits;
    with (SceneManager) {
        define(
            LogoAnimation(
                onFinish(
                    move!Title
                )
            ),
            OpeningMovie(
                onFinish(
                    move!Title
                )
            ),
            Title(
                onSelect([
                    over!(Dialog!"Test2")(
                        onSelect([
                            move!StartNewGame,
                            pop
                        ])
                    ),
                    over!(Dialog!"Test2")(
                        onSelect([
                            move!SelectSaveData,
                            pop
                        ])
                    )
                ])
            ),
            StartNewGame( //たぶん読み込み画面とか
                onFinish(
                    move!GameMainScene(
                        onFinish(
                            move!Stage //現在の状態をみていいかんじのステージに飛ぶ
                        )
                    )
                )
            ),
            SelectSaveData(
                onFinish(
                    move!Stage
                )
            ),
        );
        launch!(Title);
        //launch!(LogoAnimation);
        //launch!OpeningStage;
    }
}
