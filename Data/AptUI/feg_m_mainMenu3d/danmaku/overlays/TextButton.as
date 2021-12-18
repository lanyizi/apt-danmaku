import danmaku.utilities.Bind;

class danmaku.overlays.TextButton {
    private var _sprite: MovieClip;
    private var _button: Button;
    private var _text: TextField;
    public var onClick: Function;

    public function TextButton(sprite: MovieClip) {
        _sprite = sprite;
        _button = _sprite.button;
        _text = _sprite.textField;
        _text.setTextFormat(_global.std_config.button_textFormat);

        // 在 Flash 里设计的时候，可能需要拉伸按钮以调整大小。
        // 可这会导致文字本身也被缩放，因此需要把缩放重置为 100%
        // 但在此之前，为了在视觉（以及逻辑）上保持它原先被设计的大小，
        // 因此先以当前的缩放，去缩放一个子对象（也就是 _button）
        _button._width *= (_sprite._xscale / 100);
        _button._height *= (_sprite._yscale / 100);
        _sprite._xscale = 100;
        _sprite._yscale = 100;

        _button.onPress = Bind.noArg(this, function() {
            if (onClick) { onClick(); }
        });
    }

    public function sprite(): MovieClip { return _sprite; }

    public function getWidth(): Number { return _button._width; }
    public function setWidth(width: Number): Void {
        _button._width = width;
        layout(_text.text);
    }

    public function getText(): String { return _text.text; }
    public function setText(text: String): Void { layout(text); }

    private function layout(text: String): Void {
        // Flash 的排版，或者更准确的来说，Apt 的排版，实在是让人一言难尽……
        // 尝试了好多次，仍然连一个简单的居中都没法完全达到
        // 总之我放弃了……

        // 总之，这里尝试使用 TextField.autoSize 来实现自动居中
        // autoSize 启用之后会接管并自动修改 TextField 的坐标以及大小
        // 而我们现在需要重置坐标以及大小，因此需要禁用 autoSize
        _text.autoSize = "none";
        _text._x = 0;
        _text._width = _button._width;
        // 设置文本
        _text.text = text;
        // 重新启用 autoSize，它会根据目前的文本来对坐标以及大小进行调整
        _text.autoSize = "center";
        // 启用 autoSize 之后，我们还能获得 textHeight 等比较有用的信息
        // 由于 Apt 里也并没有 Flash 的 TextFormat.getTextExtent
        // 因此这大概是唯一一个获取文本实际大小的方式了……
        // 我们可以根据 textHeight 来计算居中所需要的坐标
        var width = _text._width;
        var height = _text._height;
        var x = (_button._width - width) * 0.5
        var y = (_button._height - height) * 0.5;

        // 禁用 autoSize，以便让我们修改坐标
        _text.autoSize = "none";
        var previous = _text._y;
        _text._x = x;
        _text._y = y;
        _text._width = width;
        _text._height = height;
    }
}