module game.stage.crystalMine.CrystalMine;

import std.json, std.algorithm, std.array, std.file, std.range;

import sbylib;

import game.Game;
import game.stage.crystalMine.StageMaterial;
import game.stage.crystalMine.CrystalMaterial;
import game.stage.crystalMine.component.Root;
import game.stage.Stage;
import std.concurrency, std.typecons;
import core.thread;

class CrystalMine : Stage {

    private Root root;
    alias root this;

    private bool paused;

    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;

    private debug bool wireVisible = false;


    private IViewport viewport;
    private Renderer renderer;

    this() {

        this.root = new Root;
        Game.getWorld3D().add(this.currentArea.entity);
        Game.getPlayer().setCenter(vec3(0));

        Core().addProcess(&step, "Stage1");

        debug addDebugActions;

        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 1;
        this.fadeRect.name = "Fade Rect";
        Game.getWorld2D().add(this.fadeRect);

        this.viewport = new AutomaticViewport(Core().getWindow);
        this.renderer = new Renderer;
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

    override Entity getStageEntity() {
        return this.currentArea.stageEntity;
    }

    override Entity getCharacterEntity() {
        return this.currentArea.characterEntity;
    }

    override Entity getMoveEntity() {
        return this.currentArea.moveEntity;
    }

    override void render() {
        auto scene = Game.getScene();
        auto screen = Core().getWindow().getScreen();
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
            assert(paused);
            paused = false;
            Game.getWorld3D().remove(this.currentArea.entity);
            root.transit(name);
            Game.getWorld3D().add(this.currentArea.entity);
            Game.getPlayer().setCenter(vec3(0));
            PointLightManager().clear();
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
            EffectManager().start(new StartEffect(this.stageName));
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

