import danmaku.Component;
import danmaku.Options;

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
        var self = this;
        _button.onPress = function() { self._slowMode = true; }
        _button.onRelease = function() { self._slowMode = false; }
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