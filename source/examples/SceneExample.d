module examples.SceneExample;

import sbylib;
import std.algorithm, std.array;
import std.math;
import game.scene;
import game.Game;

void sceneExample(string[] args) {
    auto core = Core();
    auto window = core.getWindow();
    auto renderer = new Renderer();
    auto viewport = new AspectFixViewport(window);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    core.addProcess(&AnimationManager().step, "Animation Manager");


    setGameTransition(args);


    core.start();
}

void setGameTransition(string[] args) {
    Game.initialize(args);
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
                    over!(Dialog!"新規ゲームを開始してよろしいですか？")(
                        onSelect([
                            move!StartNewGame,
                            pop
                        ])
                    ),
                    over!(Dialog!"続きからでよろしいですか？")(
                        onSelect([
                            move!StartNewGame,
                            pop
                        ])
                    )
                ])
            ),
            StartNewGame( //たぶん読み込み画面とか
                onFinish(
                    move!GameMainScene(
                        onFinish(
                            over!(Dialog!"ここまでしかできてません！ありがとうございました！！！")(
                                onSelect([
                                    move!Title,
                                    pop
                                ])
                            )
                            //move!Stage //現在の状態をみていいかんじのステージに飛ぶ
                        )
                    )
                )
            ),
            SelectSaveData(
                onFinish(
                    move!Stage
                )
            )
        );
        launch!(GameMainScene);
    }
}
