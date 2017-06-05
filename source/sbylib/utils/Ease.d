module sbylib.utils.Ease;

import sbylib.utils.EasingManager;
import std.math;

/*
EasingManagerを構築するためのクラス

auto easing = Ease.Quad.InOut.build!float();
でQuadなInOutなfloat型のeasing functionを作成し、そのEasingManagerを代入する。

和とスカラー倍の演算子オーバーロードをしている型はうまくいくはず。
*/

static class Ease {

    static {
        Type Linear() @property {
            return new Type(t => t);
        }
        Type Smooth() @property {
            return new Type(t => t*t*(3-t)/2);
        }
        Type Quad() @property {
            return new Type(t => t*t);
        }
        Type Cubic() @property {
            return new Type(t => t*t*t);
        }
        Type Quart() @property {
            return new Type(t => t*t*t*t);
        }
        Type Quint() @property {
            return new Type(t => t*t*t*t*t);
        }
        Type Sine() @property {
            return new Type(t => 1-cos(t*PI/2));
        }
        Type Circ() @property {
            return new Type(t => 1-sqrt(1-t*t));
        }
        Type Exp() @property {
            return new Type(t => pow(2, -(1-t)*10));
        }
        Type Back() @property {
            return new Type(t => t*t*(2.70158*t-1.70158));
        }
        Type SoftBack() @property {
            return new Type(t => t*t*(2*t-1));
        }

        private class Type {
            private float function(float) _func;
            this(float function(float) func) {
                _func = func;
            }

            Builder In() @property {
                return new Builder(
                        t => _func(t)
                );
            }

            Builder Out() @property {
                return new Builder(
                        t => 1-_func(1-t)
                );
            }

            Builder InOut() @property {
                return new Builder(
                        (t) {
                    if (t<0.5) {
                        return _func(t*2)/2;
                    } else {
                            return 1-_func(2-2*t)/2;
                        }
                        }
                        );
                    }
                }

                private class Builder {
                    private float delegate(float) _func;
                    this(float delegate(float) func) {
                        _func = func;
                    }

                    EasingManager!T build(T)() {
                        return new EasingManager!T(_func);
                    }
                }
    }

}
