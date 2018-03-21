module game.event.Event;

public import game.camera.CameraController;

import sbylib;

interface Event {

    void fire();
    void step();
}

class CrystalBreakEvent : Event {

    import game.Game;
    import game.effect.Effect;

    private Entity focusTarget;
    private Maybe!Effect effect;

    this(Entity focusTarget) {
        this.focusTarget = focusTarget;
    }

    override void fire() {
        Game.getPlayer().camera.focus(focusTarget);
        //this.effect = Just(EffectManager.start(new BreakEffect(focusTarget)));
    }

    override void step() {
        if (this.effect.done.getOrElse(false)) {
            this.effect = None!Effect;
            Game.getPlayer().camera.reset();
        }
    }
}
