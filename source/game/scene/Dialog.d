module game.scene.Dialog;

import game.scene.SceneBase;
import game.player.Controller;
import sbylib;

class Dialog(dstring explainMessage) : SceneProtoType {

    mixin SceneBasePack;

    private Label explain;
    private Selection[2] selections;
    private bool hasSelectorMoved;
    private bool canSelect;
    private uint selector;
    ImageEntity main;
    
    private mixin DeclareConfig!(float, "DIALOG_WIDTH", "dialog.json");
    private mixin DeclareConfig!(float, "DIALOG_HEIGHT", "dialog.json");
    private mixin DeclareConfig!(float, "TEXT_TOP", "dialog.json");
    private mixin DeclareConfig!(float, "TEXT_SIZE", "dialog.json");
    private mixin DeclareConfig!(float[3], "YES_COLOR", "dialog.json");
    private mixin DeclareConfig!(float[3], "NO_COLOR", "dialog.json");
    private mixin DeclareConfig!(float, "SELECTION_SIZE", "dialog.json");
    private mixin DeclareConfig!(float, "SELECTION_X", "dialog.json");
    private mixin DeclareConfig!(float, "SELECTION_Y", "dialog.json");
    private mixin DeclareConfig!(uint, "PROGRESS_PERIOD", "dialog.json");

    this() {
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
            this.canSelect = false;
            AnimationManager().startAnimation(
                fade(
                    setting(
                        vec4(0),
                        vec4(0,0,0,1),
                        180.frame,
                        &Ease.linear
                    )
                )
            ).onFinish({
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
            animation(
                (float a) { 
                    this.main.alpha = a;
                    this.explain.color = vec4(vec3(0), a);
                    this.selections[0].label.color = vec4(0.4) * a;
                    this.selections[1].label.color = vec4(0.4) * a;
                },
                setting(
                    0.0f,
                    1.0f,
                    30.frame,
                    &Ease.easeInOut
                )
            ),
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
        Entity box;
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
                this.material.size = vec2(this.label.getWidth, this.label.getHeight);
                this.material.color = color;
                this.box = makeEntity(Rect.create(this.label.getWidth * 1.2, this.label.getHeight * 1.2), material);
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
                            &Ease.linear
                        )
                    ),
                    animation(
                        (float p) { this.material.progress = p; },
                        setting(
                            0.0f,
                            1.0f,
                            PROGRESS_PERIOD.frame,
                            &Ease.linear
                        )
                    )
                )
            ));
        }

        void unselect() {
            if (this.anim.isJust) {
                this.anim.get.finish();
            }
            this.anim = Just(AnimationManager().startAnimation(
                multi(
                    this.label.colorAnimation(
                        setting(
                            this.label.color,
                            vec4(0.4),
                            10.frame,
                            &Ease.linear
                        )
                    ),
                    animation(
                        (float p) { this.material.progress = p;},
                        setting(
                            1.0f,
                            0.0f,
                            PROGRESS_PERIOD.frame,
                            &Ease.linear
                        )
                    )
                )
            ));
        }

        class DialogSelectionMaterial : Material {
            
            mixin declare;

            ufloat progress;
            uvec2 size;
            uvec3 color;
            int id;

            this() {
                mixin(autoAssignCode);
                super();

                this.progress = 0;
            }
        }
    }
}
