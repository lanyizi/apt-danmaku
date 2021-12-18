import danmaku.Game;
import danmaku.overlays.TextButton;
import danmaku.utilities.Bind;
import ra3.TextInputField;

// 选项界面，游戏开始之前以及游戏暂停时显示
class danmaku.overlays.Options {
    // 选项界面的 MovieClip
    private var _sprite: MovieClip;
    // 难度
    private var _difficulties: Object; // 这个对象包含下面这四个按钮，方便遍历
    private var _easy: TextButton;
    private var _medium: TextButton;
    private var _hard: TextButton;
    private var _brutal: TextButton;
    // 各种其他按钮
    private var _exit: TextButton;
    private var _about: TextButton;
    private var _settings: TextButton;
    private var _play: TextButton;

    private var _closeAbout: TextButton;

    public function Options(sprite: MovieClip, onClosed: Function) {
        _sprite = sprite;
        _sprite.onUnload = onClosed;

        // 为了省事，现在的 Options 既包含选项，也包含一个“关于”窗口
        // 两者放在不同的帧
        // 一开始先切换到选项
        _sprite.gotoAndStop("options");
        // 切换之后，下一帧开始初始化选项界面
        _sprite.onEnterFrame = Bind.noArg(this, function() {
            delete _sprite.onEnterFrame;
            initializeOptionsPanel();
        });
    }

    public function sprite(): MovieClip { return _sprite; }

    // 初始化“选项”界面
    private function initializeOptionsPanel(): Void {
        // 初始化难度按钮
        _difficulties = {};
        var getDifficulty = Bind.oneArg(this, function(name) {
            var button: TextButton = getButton(name);
            // 点击按钮时，可以切换难度
            button.onClick = Bind.noArg(this, function() {
                var game: Game = Game.instance();
                game.difficulty = Game[name.toUpperCase()];
                updateSelectedDifficulty();
            });
            _difficulties[name] = button;
        });
        getDifficulty("easy");
        getDifficulty("medium");
        getDifficulty("hard");
        getDifficulty("brutal");
        updateSelectedDifficulty();

        // 设置其他按钮
        getButton("exit").setText("退出游戏");
        getButton("about").setText("关于");
        getButton("settings").setText("设置");
        getButton("play").setText("开始游戏");

        _exit.onClick = function() {
            fscommand("CallGameFunction", "%ExitApplication");
        };
        _about.onClick = Bind.noArg(this, function() {
            // 切换到“关于”界面
            _sprite.gotoAndStop("about");
            // 并在下一帧初始化“关于”界面
            _sprite.onEnterFrame = Bind.noArg(this, function() {
                delete _sprite.onEnterFrame;
                initializeAboutPanel();
            });
        });
        _settings.onClick = function() {
            // 切换到游戏设置
            _global.gSM.changeMainScreen(_global.SCREEN.FEG_OPTIONS);
        };
        _play.onClick = Bind.noArg(this, function() {
            _sprite.removeMovieClip();
        });
    }

    // 初始化“关于”界面
    private function initializeAboutPanel(): Void {
        getButton("closeAbout");
        _closeAbout.onClick = Bind.noArg(this, function() {
            _sprite.gotoAndStop("options");
            _sprite.onEnterFrame = Bind.noArg(this, function() {
                delete _sprite.onEnterFrame;
                initializeOptionsPanel();
            });
        });
        _closeAbout.setText("X");

        setLink("tpdp", "http://www.fo-lens.net/enbu_ap/download.html#mt");
        setLink("sketchfab", "https://buff.ly/2E8uq0p");
        setLink("hsopcb", "https://www.melonbooks.co.jp/detail/detail.php?product_id=928313");
        setLink("shadertoy", "https://www.shadertoy.com/view/4s33zf");
    }

    private function getButton(name: String): TextButton {
        var buttonSprite = _sprite[name + "Button"];
        this["_" + name] = new TextButton(buttonSprite);
        return this["_" + name];
    }

    private function setLink(name: String, url: String): Void {
        var link: TextInputField = _sprite[name + "Link"];
        // 在文本框里设置链接
        var codes: Array = [];
        var length = url.length;
        for (var i = 0; i < length; ++i) {
            codes.push(url.charCodeAt(i));
        }
        link.setContents(codes.join(","));
    }

    private function updateSelectedDifficulty(): Void {
        var game: Game = Game.instance();
        for (var difficulty: String in _difficulties) {
            var button: TextButton = _difficulties[difficulty];
            if (game.difficulty === Game[difficulty.toUpperCase()]) {
                button.setText("X");
            }
            else {
                button.setText("");
            }
        }
    }
}