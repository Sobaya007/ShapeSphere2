module game.stage.crystalMine.CrystalMine;

import std.json, std.algorithm, std.array, std.file, std.range;

import sbylib;

import game.Game;
import game.stage.crystalMine.StageMaterial;
import game.stage.crystalMine.CrystalMaterial;
import game.stage.crystalMine.component.Root;
import game.stage.Stage;

class CrystalMine : Stage {

    private Root root;
    alias root this;

    private bool paused;

    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;

    private debug bool wireVisible = false;


    private Renderer renderer;

    this() {

        Core().addProcess(&this.step, "CrystalMine step");

        this.renderer = new Renderer;


        Core().getWindow().getScreen().setClearColor(vec4(0,0,0,1));
        Game.getWorld3D().addRenderGroup("Crystal", new TransparentRenderGroup(Game.getWorld3D().camera));


        this.root = new Root;
        Game.getWorld3D().add(this.currentArea.entity);
        Game.getPlayer().setCenter(vec3(0,1,0));


        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 0;
        this.fadeRect.name = "Fade Rect";
        Game.getWorld2D().add(this.fadeRect);


        debug addDebugActions;

        /*
        import game.effect.StartEffect;
        auto startEffect = new StartEffect(this.stageName);
        auto anim = AnimationManager().startAnimation(
            multi(
                animation(
                    (vec4 color) => this.fadeRect.color = color,
                    setting(
                        vec4(0,0,0,1),
                        vec4(0),
                        60.frame,
                        &Ease.easeInOut
                    )
                ),
                sequence(
                    animation((void delegate() kill) {
                        Game.getPlayer().camera.trace(this.root.cameraMove.trail, kill);
                    }, false),
                    animation(
                        (vec4 color) => this.fadeRect.color = color,
                        setting(
                            vec4(0),
                            vec4(0,0,0,1),
                            40.frame,
                            &Ease.easeInOut
                        )
                    ),
                    single({Game.getPlayer().camera.reset();}),
                    wait(120.frame),
                    animation(
                        (vec4 color) => this.fadeRect.color = color,
                        setting(
                            vec4(0,0,0,1),
                            vec4(0),
                            40.frame,
                            &Ease.easeInOut
                        )
                    ),
                    wait(120.frame),
                ),
                startEffect
            )
        );

        Core().getKey().justPressed(KeyButton.Enter).add({
            if (anim is null) return;
            anim.forceFinish();
            anim = null;
            startEffect.abridge();
            AnimationManager().startAnimation(
                sequence(
                    multi(
                        animation(
                            (vec4 color) => this.fadeRect.color = color,
                            setting(
                                this.fadeRect.color,
                                vec4(0,0,0,1),
                                60.frame,
                                &Ease.easeInOut
                            )
                        ),
                        startEffect,
                    ),
                    single({ Game.getPlayer().camera.reset(); }),
                    wait(20.frame),
                    animation(
                        (vec4 color) => this.fadeRect.color = color,
                        setting(
                            vec4(0,0,0,1),
                            vec4(0,0,0,0),
                            30.frame,
                            &Ease.easeInOut
                        )
                    ),
                )
            );
        });
        */
    }


    void step() {
        if (!paused) {
            this.currentArea.step();
        }
    }

    override void pause() {
        paused = true;
    }

    override void resume() {
        paused = false;
    }

    override Entity mapEntity() {
        return this.currentArea.mapEntity;
    }

    override Entity otherEntity() {
        return this.currentArea.otherEntity;
    } 

    override Entity characterEntity() {
        return this.currentArea.characterEntity;
    }

    override Entity moveEntity() {
        return this.currentArea.moveEntity;
    }

    override void render() {
        auto screen = Core().getWindow().getScreen();
        auto viewport = Game.getScene.viewport;
        renderer.render(Game.getWorld3D(), screen, viewport, "regular");
        renderer.render(Game.getWorld3D(), screen, viewport, "transparent");
        screen.blitsTo(Game.getBackBuffer(), BufferBit.Color);
        renderer.render(Game.getWorld3D(), screen, viewport, "Crystal");
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport, "regular");
        renderer.render(Game.getWorld2D(), screen, viewport, "transparent");
    }

    override void transit(string name) {
        paused = true;
        AnimationManager().startAnimation(
            new Animation!vec4(color => this.fadeRect.color = color,
                setting(
                    vec4(0,0,0,0),
                    vec4(0,0,0,1),
                    60.frame,
                    &Ease.linear
                )
            )
        ).onFinish({
            Game.getScene().finish();
            assert(paused);
            paused = false;
            Game.getWorld3D().remove(this.currentArea.entity);
            PointLightManager().clear();
            root.transit(name);
            Game.getWorld3D().add(this.currentArea.entity);
            Game.getPlayer().setCenter(vec3(0));
            AnimationManager().startAnimation(
                new Animation!vec4(color => this.fadeRect.color = color,
                    setting(
                        vec4(0,0,0,1),
                        vec4(0,0,0,0),
                        60.frame,
                        &Ease.linear
                    )
                )
            );
        });
    }

    void reload() {
        Core().addProcess((Process proc) {
            this.root.reload();
            proc.kill();
        }, "stage update");
    }

    override void save() {
        root.save();
    }

    //void addCrystal(vec3 pos) {
    //    this.currentArea.addCrystal(root[this.currentArea.name], pos);
    //    this.save();
    //}

    //void addLight(vec3 pos) {
    //    this.currentArea.addLight(root[this.currentArea.name], pos);
    //    this.save();
    //}

    private debug void addDebugActions() {
        import game.effect.Effect;
        import game.effect.StartEffect;

        Core().getKey().justPressed(KeyButton.KeyL).add(&reload);
        Core().getKey().justPressed(KeyButton.KeyP).add({
            Game.getPlayer().setCenter(this.currentArea.debugPos);
        });

        Core().getKey().justPressed(KeyButton.KeyU).add({
            AnimationManager().startAnimation(new StartEffect(this.stageName));
        });

        Core().getKey().justPressed(KeyButton.KeyT).add({
            wireVisible = !wireVisible;
            this.currentArea.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        });

        Core().getKey().justPressed(KeyButton.KeyQ).add({
            auto pos = Game.getPlayer().getCenter();
            this.currentArea.debugPos = pos;
            this.root.save();
        });

        Core().addProcess((proc) {
            this.currentArea.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        }, "po");
    }
}

