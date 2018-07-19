module game.scene.Dialog;

import game.scene.SceneBase;
import game.player.Controller;
import sbylib;
import dconfig;

class Dialog(dstring explainMessage) : SceneProtoType {

    mixin SceneBasePack;
    mixin HandleConfig;

    private Label explain;
    private Selection[2] selections;
    private bool hasSelectorMoved;
    private bool canSelect;
    private uint selector;
    ImageEntity main;
    
    @config(ConfigPath("dialog.json")) {
        float DIALOG_WIDTH;
        float DIALOG_HEIGHT;
        float TEXT_TOP;
        float TEXT_SIZE;
        float[3] YES_COLOR;
        float[3] NO_COLOR;
        float SELECTION_SIZE;
        float SELECTION_X;
        float SELECTION_Y;
        uint PROGRESS_PERIOD;
    }

    this() {
        this.initializeConfig();
        super();
        {
            ImageEntityFactory factory;
            factory.width = DIALOG_WIDTH;
            factory.height = DIALOG_HEIGHT;
            this.main = factory.make(ImagePath("message.png"));
        }

        {
            LabelFactory factory;
            factory.text = explainMessage;
            factory.height = TEXT_SIZE;
            factory.wrapWidth = 1.2;
            this.explain = factory.make();
            this.explain.top = TEXT_TOP;
            this.main.addChild(this.explain);
        }

        this.selections = [
            new Selection("YES", vec2(-SELECTION_X, SELECTION_Y), vec3(YES_COLOR)),
            new Selection("NO",  vec2(+SELECTION_X, SELECTION_Y), vec3(NO_COLOR)),
        ];

        this.main.addChild(this.selections[0]);
        this.main.addChild(this.selections[1]);

        addEntity(main);

        addEvent(() => Controller().justPressed(CButton.Left), {changeSelector(-1);});
        addEvent(() => Controller().justPressed(CButton.Right), {changeSelector(+1);});
        addEvent(() => Controller().justPressed(CButton.Decide), {
            if (!this.hasSelectorMoved) return;
            if (!canSelect) return;
            IAnimation anim;
            if (this.selector == 0) {
                anim = 
                    fade(
                        setting(
                            vec4(0),
                            vec4(0,0,0,1),
                            180.frame,
                            Ease.Linear
                        )
                    );
            } else {
                anim = 
                    alphaAnimation(
                        setting(
                            1.0f,
                            0.0f,
                            20.frame,
                            Ease.InOut
                        )
                    );
            }
            this.canSelect = false;
            AnimationManager().startAnimation(anim)
            .onFinish({
                this.select(this.selector);
            });
        });
    }

    override void initialize() {
        this.hasSelectorMoved = false;
        this.canSelect = false;
        this.selector = 0;
        this.selections[0].material.progress = 0;
        this.selections[1].material.progress = 0;

        AnimationManager().startAnimation(
            alphaAnimation(
                setting(
                    0.0f,
                    1.0f,
                    30.frame,
                    Ease.InOut
                )
            )
        ).onFinish({ this.canSelect = true;});

    }

    void changeSelector(int d) {
        if (!canSelect) return;
        if (hasSelectorMoved) {
            this.selections[this.selector].unselect();
        }
        this.selector += d;
        if (this.selector == -1) this.selector = 0;
        if (this.selector == this.selections.length) this.selector = this.selections.length-1;
        this.selections[this.selector].select();
        this.hasSelectorMoved = true;
    }

    class Selection {
        TypedEntity!(GeometryRect, DialogSelectionMaterial) box;
        private Label label;
        private vec3 color;
        private Maybe!AnimationProcedure anim;
        private DialogSelectionMaterial material;

        alias box this;

        this(dstring text, vec2 pos, vec3 color) {
            this.color = color;
            {
                LabelFactory factory;
                factory.text = text;
                factory.height = SELECTION_SIZE;
                factory.textColor = vec4(0.8);
                this.label = factory.make();
                this.label.pos.z = 0.2;
            }
            {
                this.material = new DialogSelectionMaterial;
                this.material.size = vec2(this.label.width, this.label.height);
                this.material.color = vec4(color, 0);
                this.box = makeEntity(Rect.create(this.label.width * 1.2, this.label.height * 1.2), material);
                this.box.pos = vec3(pos, 0.1);
                this.box.addChild(this.label);
            }
        }

        void select() {
            this.anim = Just(AnimationManager().startAnimation(
                multi(
                    this.label.colorAnimation(
                        setting(
                            this.label.color,
                            vec4(vec3(0.1), 1),
                            10.frame,
                            Ease.Linear
                        )
                    ),
                    animation(
                        (float p) { this.material.progress = p; },
                        setting(
                            0.0f,
                            1.0f,
                            PROGRESS_PERIOD.frame,
                            Ease.Linear
                        )
                    )
                )
            ));
        }

        void unselect() {
            if (this.anim.isJust) {
                this.anim.unwrap().finish();
            }
            this.anim = Just(AnimationManager().startAnimation(
                multi(
                    this.label.colorAnimation(
                        setting(
                            this.label.color,
                            vec4(0.4),
                            10.frame,
                            Ease.Linear
                        )
                    ),
                    animation(
                        (float p) { this.material.progress = p;},
                        setting(
                            1.0f,
                            0.0f,
                            PROGRESS_PERIOD.frame,
                            Ease.Linear
                        )
                    )
                )
            ));
        }

        class DialogSelectionMaterial : Material {
            
            mixin ConfigureMaterial;

            ufloat progress;
            uvec2 size;
            uvec4 color;
            int id;

            this() {
                mixin(autoAssignCode);
                super();

                this.progress = 0;
            }
        }
    }

    private auto alphaAnimation(AnimSetting!float setting) {
        return animation(
            (float a) { 
                this.main.alpha = a;
                this.explain.color = vec4(vec3(0), a);
                this.selections[0].label.color = vec4(0.4) * a;
                this.selections[1].label.color = vec4(0.4) * a;
                this.selections[0].box.color.a = a;
                this.selections[1].box.color.a = a;
            },
            setting
        );
    }
}
