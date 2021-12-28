
import danmaku.utilities.Bind;

// 控制游戏里，人物的剧情对话框
class danmaku.overlays.GameDialogue {
    private static var FADE_TIME: Number = 8; // 淡入淡出所需要的时间
    private var _sprite: MovieClip;
    private var _character: MovieClip;  // 显示立绘
    private var _title: TextField;      // 对话标题
    private var _text: TextField;       // 显示对话
    private var _hint: TextField;       // 显示操作提示
    private var _hitRegion: Button;     // 供玩家点击
    private var _step: Number;          // 当前对话序号
    private var _finished: Boolean;     // 对话是否已经放完
    private var _data: Array;
    private var _currentTimer: Number;
    private var _currentAction: Function;

    public function GameDialogue(sprite: MovieClip, data: Array) {
        _sprite = sprite;
        _character = _sprite.character;
        _title = _sprite.title;
        _text = _sprite.text;
        _hint = _sprite.hint;
        _hitRegion = _sprite.hitRegion;
        _step = -1;
        _finished = false;
        _data = data;
        _currentTimer = 0;
        _currentAction = null;
        _hitRegion.onPress = Bind.noArg(this, startSwitch);
        // 开始淡入第一个画面
        _character._alpha = 0;
        loadNext();
    }

    // 在每一帧都尝试进行处理
    public function update(): Void {
        if (!_currentAction) {
            return;
        }
        _currentAction();
    }

    public function isFinished(): Boolean { return _finished; }

    // 开始切换到下一个画面
    private function startSwitch(): Void {
        // 已经正在切换画面的话
        if (_currentAction) {
            // 就加速切换
            _currentTimer = 0;
            return;
        }
        _currentTimer = FADE_TIME;
        _currentAction = Bind.noArg(this, fadeOut);
        // 隐藏提示
        _hint._visible = false;
    }

    // 淡出当前画面
    private function fadeOut(): Void {
        var nextStep = _step + 1;
        if (_currentTimer > 0) {
            --_currentTimer;
            var percentage = _currentTimer * 100 / FADE_TIME;
            if (nextStep >= _data.length) {
                // 正在淡出最后一段对话，因此把整个对话框一起淡出了
                _sprite._alpha = percentage;
            }
            else if (_data[_step].character !== _data[nextStep].character) {
                // 下一段的立绘不一样，因此可以淡出立绘
                _character._alpha = percentage;
                // 以及文本
                _title._alpha = percentage;
                _text._alpha = percentage;
            }
            return;
        }
        if (nextStep < _data.length) {
            // 淡出完毕，需要开始淡入下一个画面了
            _currentAction = Bind.noArg(this, loadNext);
            return;
        }
        // 假如对话都放完了，那么是时候退出了（
        _sprite.removeMovieClip();
        _finished = true;
        _currentAction = null;
    }

    // 加载下一个画面
    private function loadNext(): Void {
        ++_step;
        _currentTimer = FADE_TIME;
        var current = _data[_step];
        if (current.character) {
            // 切换到有着相应人物立绘的帧
            _character.gotoAndStop(current.character);
        }
        // 重置文本
        if (current.title) {
            _title.text = current.title;
        }
        _text.text = "";
        _currentAction = fadeIn;
    }

    // 开始淡入新的画面
    private function fadeIn(): Void {
        if (_currentTimer > 0) {
            --_currentTimer;
            var percentage = (FADE_TIME - _currentTimer) * 100 / FADE_TIME;
            var first = _step === 0;
            var current = _data[_step];
            if (first || current.character !== _data[_step - 1].character) {
                // 淡入立绘
                _character._alpha = percentage;
                _title._alpha = percentage;
                _text._alpha = percentage;
            }
            if (current.text) {
                var t: String = current.text;
                var length = percentage * t.length / 100;
                length = Math.min(Math.max(0, Math.floor(length)), t.length);
                danmaku.Main.log("Length: " + length);
                // 开始显示文字
                _text.text = t.substr(0, length);
            }
            return;
        }
        // 淡入完毕之后
        _currentAction = Bind.noArg(this, endSwitch);
    }

    // 切换到了下一个画面
    private function endSwitch(): Void {
        var current = _data[_step];
        if (current.character) {
            _character._alpha = 100;
        }
        if (current.title) {
            _title._alpha = 100;
        }
        if (current.text) {
            _text.text = current.text;
        }
        // 没有别的东西需要做的了，回到空闲状态等待玩家点击鼠标
        _currentAction = null;
    }
}