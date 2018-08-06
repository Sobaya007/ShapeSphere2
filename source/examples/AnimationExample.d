module examples.AnimationExample;

import sbylib;

void animationExample() {
    
    auto universe = Universe.createFromJson(ResourcePath("world/basic.json"));
    
    auto world = universe.getWorld("world").unwrap();
    
    auto box = world.findByName("box").wrapRange().unwrap();

    box.animate(
        moveTo(vec3(+4,2,+4), 60.frame, Ease.Linear),
        moveTo(vec3(-4,2,+4), 60.frame, Ease.Linear),
        moveTo(vec3(-4,2,-4), 60.frame, Ease.Linear),
        moveTo(vec3(+4,2,-4), 60.frame, Ease.Linear)
    )
    .repeat();

    box.animate(
        rot(vec3(0,1,0), 360.deg, 60.frame * 4, Ease.Linear)
    )
    .repeat();

    Core().start();
}
