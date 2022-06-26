import danmaku.Component;
import danmaku.components.Character;

class danmaku.components.Flare extends Component {
    private var _speed: Number;
    private var _rotation: Number;
    private var _dx: Number;        // Normalized direction
    private var _dy: Number;
    private var _vx: Number;        // Actual velocity,
    private var _vy: Number;        //      = _direction * _speed
    private var _sprite: MovieClip; // The MovieClip of this bullet
    private var _exploded: Boolean;
    public var expireSpeed: Number;
    public var life: Number;
    public var owner: Character;
    public var xScale: Number;
    public var yScale: Number;
    public var alpha: Number;       // Value to be set toMovieClip._alpha
    public var alphaSpeed: Number;  // Value to be added to this.alpha
    public var maxAlpha: Number;
    public var explodeFlareId: String;

    public function Flare() {
        _speed = 0;
        _rotation = 0;
        _dx = 0;
        _dy = -1;
        _vx = 0;
        _vy = 0;
        _exploded = false;
        expireSpeed = 1;
        life = 30;
        xScale = 1;
        yScale = 1;
        alpha = 100;
        alphaSpeed = 0;
        maxAlpha = 100;
    }

    public function getDirection(): Object { return { x: _dx, y: _dy }; }
    public function setDirection(d: Object) {
        var dx = d.x;
        var dy = d.y;
        var length = Math.sqrt(dx * dx + dy * dy);
        if (length === 0) {
            // invalid
            return;
        }
        _rotation = Math.atan2(dy, dx) * 180 / Math.PI + 90;
        dx /= length;
        dy /= length;
        _dx = dx;
        _dy = dy;
        _vx = dx * _speed;
        _vy = dy * _speed;
    }

    public function getSpeed(): Number { return _speed; }
    public function setSpeed(s: Number) {
        _speed = s;
        _vx = _dx * _speed;
        _vy = _dy * _speed;
    }

    private function awake(): Void {
        _sprite = _self.sprite();
        _sprite._alpha = 0;
    }

    private function start(): Void {
        _sprite._xscale = xScale * 100;
        _sprite._yscale = yScale * 100;
        _self.updateInitialPosition();
    }

    private function update(): Void {
        if (alpha < maxAlpha) {
            alpha += alphaSpeed;
        }
        _sprite._alpha = alpha;
        var p = _self.getPosition();
        // Calculate new coordinates
        p.x = p.x + _vx;
        p.y = p.y + _vy;
        _self.setPosition(p);
        // rotation
        _sprite._rotation = _rotation;

        if (owner && (owner.hitpoint <= 0 || !owner.gameObject())) {
            explode();
        }

        life -= expireSpeed;
        if (life <= 0) {
            expire();
        }
    }

    public function expire(): Void {
        // force die
        if (life > 0) {
            life = 0;
        }
        expireSpeed = 1;

        // default
        _sprite._alpha = 100;
        var factor = (25 - (life * life)) / 0.25;
        if (factor <= 0) {
            _world.destroy(_self);
        }
        else {
            _sprite._alpha = factor;
            _sprite._xscale = xScale * factor;
            _sprite._yscale = yScale * factor;
        }
    }

    public function explode(): Void {
        if (_exploded) {
            return;
        }
        _exploded = true;
        // force die
        if (life > 0) {
            life = 0;
        }
        if (!explodeFlareId) {
            return;
        }
        // create flare
        var flareObject = _world.instantiate(explodeFlareId);
        if (flareObject.depth() < _self.depth()) {
            _self.swapDepth(flareObject);
        }
        flareObject.setPosition(_self.getPosition());
        var flare: Flare = flareObject.addComponent(new Flare());
        flare.life = flareObject.sprite()._totalframes;
        flare._sprite._alpha = 100;
        flare.alpha = 100;
        flare.maxAlpha = 100;
        flare.setSpeed(Math.sqrt(_speed) / 2);
        flare.setDirection(getDirection());
    }
}