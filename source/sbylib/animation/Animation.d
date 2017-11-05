module sbylib.animation.Animation;

alias Ease = float function(float);
alias EntityOperator = void function(Entity);

struct FrameEvaluator(T) {

    private T start;
    private T end;
    private uint period;
    private Ease ease;

    this(T start, T end, uint period, Ease ease) {
        this.start = start;
        this.end = end;
        this.period = period;
        this.ease = ease;
    }

    T eval(uint frame) {
        return start + (end - start) * ease(cast(float)frame / period);
    }
}

interface IAnimation {
    void eval(uint frame);
}

struct Animation(T) : IAnimation {

    private Entity entity;
    private EntityOperator operator;
    private FrameEvaluator!T evaluator;


    this(Entity entity, EntityOperator operator, FrameEvaluator!T evaluator) {
        this.entity = entity;
        this.operator = operator;
        this.evaluator = evaluator;
    }

    void eval(uint frame) {
        operartor(entity, evaluator.eval(frame));
    }
}

IAnimation rotate(T)(Entity entity, FrameEvaluator!T evaluator) {
}
