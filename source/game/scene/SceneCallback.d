module game.scene.SceneCallback;

import game.scene.SceneTransition;

alias FinishCallback = SceneTransition delegate();
alias SelectCallback = SceneTransition delegate(size_t);

FinishCallback onFinish(SceneTransition transit) {
    return () => transit;
}

SelectCallback onSelect(SceneTransition[] transit) {
    return idx => transit[idx];
}
