import danmaku.Component;
import danmaku.Options;
import danmaku.utilities.Bind;

// 处理玩家输入，主要是靠鼠标坐标来移动人物
// 但是，它也通过预先放在场景里的一个按钮来检测鼠标点击
class danmaku.components.PlayerControl extends Component {
    private static var SLOW_SPEED = 10;
    private static var FAST_SPEED = 20;
    private var _options: Options;
    private var _button: Button;
    private var _worldMovie: MovieClip;
    private var _selfSprite: MovieClip;
    private var _previousDx: Number;
    private var _slowMode: Boolean;
    public var slowMode: Number;

    public function PlayerControl(button: Button) {
        super();
        _button = button;
        _previousDx = 0;
        _slowMode = false;
        slowMode = 0;
        _button.onPress = Bind.noArg(this, function() {
            _slowMode = true;
        });
        _button.onRelease = Bind.noArg(this, function() {
            _slowMode = false;
        });
    }

    private function start(): Void {
        _options = Options.instance();
        _worldMovie = _world.movieClip();
        _selfSprite = _self.sprite();

        _button._x = -_world.width();
        _button._y = -_world.height();
        _button._width = _world.width() * 4;
        _button._height = _world.height() * 4;
    }

    private function update(): Void {
        var p = _self.getPosition();
        var dx = 0;
        var dy = 0;
        // 曾经以为可以检测键盘输入，没想到红警3里却不支持（
        // 可能以后可以靠文本输入框之类的曲线救国一下 23333
        // 但总之，目前就只能靠鼠标了（
        if (_options.useKeyboardInput) {
            var speed = FAST_SPEED;
            if (Key.isDown(_options.keySlow)) {
                _slowMode = true;
                slowMode = 1;
                speed = SLOW_SPEED;
            }
            if (Key.isDown(_options.keyLeft) || Key.isDown(Key.LEFT)) {
                dx = -speed;
            }
            if (Key.isDown(_options.keyRight) || Key.isDown(Key.RIGHT)) {
                dx = +speed;
            }
            if (Key.isDown(_options.keyUp) || Key.isDown(Key.UP)) {
                dy = -speed;
            }
            if (Key.isDown(_options.keyDown) || Key.isDown(Key.DOWN)) {
                dy = +speed;
            }
        }
        else {
            if (!_slowMode) {
                slowMode -= 0.2;
            }
            else {
                slowMode = 1;
            }
            dx = _worldMovie._xmouse - p.x;
            dy = _worldMovie._ymouse - p.y;
            if (slowMode > 0) {
                var limit = (1 / slowMode) * SLOW_SPEED;
                var squareLength = dx * dx + dy * dy;
                if (squareLength > (limit * limit)) {
                    var scale = limit / Math.sqrt(squareLength);
                    dx *= scale;
                    dy *= scale;
                }
            }
        }

        var rotation = (_previousDx + dx / 2) / 2;
        rotation = rotation > 90
            ? 90
            : (rotation < -90 ? -90 : rotation);
        _selfSprite._rotation = rotation;
        _previousDx = rotation;

        p.x += dx;
        p.y += dy;
        _self.setPosition(p);
    }
}