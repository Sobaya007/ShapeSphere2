module laboratory.LaboratoryConsole;

import sbylib;

class LaboratoryConsole : Console {

    enum LINE_MAX = 10;

    protected override void handle(KeyButton button) {
        if (button == KeyButton.Enter) {
            import std.array : back;
            interpret(this.inputString);
        }
        super.handle(button);

        import std.range : drop;
        this.text = this.text.drop(this.text.length-LINE_MAX);
    }

    private void interpret(string text) {
    }
}
