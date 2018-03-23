module game.stage.crystalMine.CrystalMine;

import std.json, std.algorithm, std.array, std.file, std.range;

import sbylib;

import game.Game;
import game.stage.crystalMine.StageMaterial;
import game.stage.crystalMine.CrystalMaterial;
import game.stage.crystalMine.component;
import game.stage.Stage;
import std.concurrency, std.typecons;
import core.thread;

class CrystalMine : Stage {

    import game.stage.crystalMine.component.Area;

    private Area area;

    private bool paused;

    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;

    private debug bool wireVisible = false;

    enum path = "Resource/stage/Stage1.json";

    private JSONValue root;

    private IViewport viewport;
    private Renderer renderer;

    this() {
        this.root = parseJSON(readText(path)).object();
        this.area = this.areas.find!(a => a.name == startArea).front;
        Game.getWorld3D().add(this.area.entity);
        this.area.load();

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

    auto obj() {
        return root.object();
    }

    string stageName() {
        return obj["StageName"].str();
    }

    string startArea() {
        return obj["StartArea"].str();
    }

    void startArea(string s) {
        obj["StartArea"] = s;
    }

    auto areas() {
        auto root = obj["Areas"].array;
        return root.length.iota.map!(i => Area(i, root));
    }

    void step() {
        if (!paused) {
            this.area.step();
        }
    }

    override void pause() {
        paused = true;
    }

    override void resume() {
        paused = false;
    }

    override Entity getStageEntity() {
        return this.area.stageEntity;
    }

    override Entity getCharacterEntity() {
        return this.area.characterEntity;
    }

    override Entity getMoveEntity() {
        return this.area.moveEntity;
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
            Game.getWorld3D().remove(this.area.entity);
            PointLightManager().clear();
            auto next = this.areas.find!(a => a.name == name).front;
            Game.getWorld3D().add(next.entity);
            Game.getPlayer().setCenter(vec3(0));
            next.load();
            this.area = next;
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
            this.root = parseJSON(readText(path)).object();
            this.area = this.areas.find!(a => a.name == this.area.name).front;
            proc.kill();
        }, "stage update");
    }

    override void save() {
        write(path, root.toJSON(true));
    }

    void addCrystal(vec3 pos) {
        this.area.addCrystal(root[this.area.name], pos);
        this.save();
    }

    void addLight(vec3 pos) {
        this.area.addLight(root[this.area.name], pos);
        this.save();
    }

    private debug void addDebugActions() {
        import game.effect.Effect;
        import game.effect.StartEffect;

        Core().getKey().justPressed(KeyButton.KeyL).add(&reload);
        Core().getKey().justPressed(KeyButton.KeyP).add({
            Game.getPlayer().setCenter(this.area.debugPos);
        });

        Core().getKey().justPressed(KeyButton.KeyU).add({
            EffectManager().start(new StartEffect(this.stageName));
        });

        Core().getKey().justPressed(KeyButton.KeyT).add({
            wireVisible = !wireVisible;
            this.area.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        });

        Core().getKey().justPressed(KeyButton.KeyQ).add({
            auto pos = Game.getPlayer().getCenter();
            this.area.debugPos = pos;
            write(path, root.toJSON(true));
        });

        Core().addProcess((proc) {
            this.area.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        }, "po");
    }
}

