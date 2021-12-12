class danmaku.overlays.TextButton {
    private var _sprite: MovieClip;
    private var _button: Button;
    private var _text: TextField;
    public var onClick: Function;

    public function TextButton(sprite: MovieClip) {
        _sprite = sprite;
        _button = _sprite.button;
        _text = _sprite.textField;
        var self = this;
        _button.onPress = function() {
            if (self.onClick) { self.onClick(); }
        };
    }

    public function sprite(): MovieClip { return _sprite; }

    public function getWidth(): Number { return _button._width; }
    public function setWidth(width: Number) {
        _button._width = width;
        _text._width = width;

    }

    public function getText(): String { return _text.text; }
    public function setText(text: String) {
        _text.autoSize = "center";
        _text.text = text;
        trace("setext, _text: " + _text + ", _text.text: " + _text.text);
        _text._y = _sprite._height * 0.5 - _text.textHeight * 0.5;
        trace("ty" + _text._y + " th" + _text._height + " tth" + _text.textHeight + " ph" + _sprite._height);
    }
}