import danmaku.Component;
import danmaku.GameObject;
import danmaku.components.Character;

class danmaku.components.Bullet extends Component {
    private var _speed: Number;
    private var _rotation: Number;
    private var _length: Number;    // Positive. if 0: circle; not 0: bar
    private var _dx: Number;        // Normalized direction
    private var _dy: Number;
    private var _vx: Number;        // Actual velocity,
    private var _vy: Number;        //      = _direction * _speed
    private var _ex: Number;        // Basically, _direction * length
    private var _ey: Number;        //      if not 0: bullet is a bar
    private var _sprite: MovieClip; // The MovieClip of this bullet
    private var _exploded: Boolean;
    public var radius: Number;
    public var life: Number;
    public var owner: Character;
    public var target: Character;
    public var damage: Number;
    public var alpha: Number;       // Value to be set toMovieClip._alpha
    public var alphaSpeed: Number;  // Value to be added to this.alpha
    public var maxAlpha: Number;
    public var explodeFlareId: String;

    public function Bullet() {
        _speed = 0;
        _rotation = 0;
        _length = 0;
        _dx = 0;
        _dy = -1;
        _vx = 0;
        _vy = 0;
        _ex = 0;
        _ey = 0;
        _exploded = false;
        radius = 0;
        life = 30;
        damage = 1;
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
            return;
        }
        _rotation = Math.atan2(dy, dx) * 180 / Math.PI + 90;
        dx /= length;
        dy /= length;
        _dx = dx;
        _dy = dy;
        _vx = dx * _speed;
        _vy = dy * _speed;
        _ex = dx * _length;
        _ey = dy * _length;
    }

    public function getSpeed(): Number { return _speed; }
    public function setSpeed(s: Number) {
        _speed = s;
        _vx = _dx * _speed;
        _vy = _dy * _speed;
    }

    public function getLength(): Number { return _length; }
    public function setLength(l: Number) {
        _length = l;
        _ex = _dx * _length;
        _ey = _dy * _length;
    }

    private function awake(): Void {
        _sprite = _self.sprite();
        _sprite._alpha = 0;
    }

    private function start(): Void {
        _self.updateInitialPosition();
    }

    private function update(): Void {
        if (alpha < maxAlpha) {
            alpha += alphaSpeed;
            _sprite._alpha = alpha;
        }
        var p = _self.getPosition();
        // Calculate new coordinates
        p.x = p.x + _vx;
        p.y = p.y + _vy;
        _self.setPosition(p);
        // rotation
        _sprite._rotation = _rotation;

        if (owner && owner.hitpoint < 0) {
            explode();
        }

        --life;
        if (life <= 0) {
            expire();
        }
    }

    private function lateUpdate(): Void {
        var tg: GameObject = target.gameObject();
        if (life <= 0 || !target || !tg) {
            return;
        }

        // Collision detection, two lines:
        // Line1: (ppx, ppy) ~ (cpx, cpy)
        var cp = _self.getPosition();
        var pp = _self.previousPosition();
        var cpx = cp.x + _ex;
        var cpy = cp.y + _ey;
        var ppx = pp.x;
        var ppy = pp.y;

        // Line2: (pqx, pqy) ~ (cqx, cqy)
        var cq = tg.getPosition();
        var pq = tg.previousPosition();
        var cqx = cq.x;
        var cqy = cq.y;
        var pqx = pq.x;
        var pqy = pq.y;

        // Collision detection: Check if intersect
        var dpx = cpx - ppx;
        var dpy = cpy - ppy;
        var dqx = cqx - pqx;
        var dqy = cqy - pqy;
        var delta = dqx * dpy - dqy * dpx;
        if (delta !== 0) { // delta === 0 => parallel segments
            var s = (dpx * (pqy - ppy) + dpy * (ppx - pqx)) / delta;
            var t = (dqx * (ppy - pqy) + dqy * (pqx - ppx)) / (-delta);
            if ((0 <= s && s <= 1) && (0 <= t && t <= 1)) {
                // segment intersected
                target.onShot(damage);
                explode();
                return;
            }
        }

        var threshold = radius + target.radius;
        // Collision detection: minimum distance
        // naiive implementation with distance between point and segment
        // target point, this segment
        var d;
        d = distanceSegmentPoint(ppx, ppy, cpx, cpy, dpx, dpy, pqx, pqy);
        if (d <= threshold) {
            target.onShot(damage);
            explode();
            return;
        }
        d = distanceSegmentPoint(ppx, ppy, cpx, cpy, dpx, dpy, cqx, cqy);
        if (d <= threshold) {
            target.onShot(damage);
            explode();
            return;
        }
        d = distanceSegmentPoint(pqx, pqy, cqx, cqy, dqx, dqy, ppx, ppy);
        if (d <= threshold) {
            target.onShot(damage);
            explode();
            return;
        }
        d = distanceSegmentPoint(pqx, pqy, cqx, cqy, dqx, dqy, cpx, cpy);
        if (d <= threshold) {
            target.onShot(damage);
            explode();
            return;
        }
    }

    private static function distanceSegmentPoint(
        s0x: Number, s0y: Number,
        s1x: Number, s1y: Number,
        sxLen: Number, syLen: Number,
        px: Number, py: Number): Number {

        var squareLength = sxLen * sxLen + syLen * syLen;
        if (squareLength === 0) {
            // zero length segment
            var d0x = s0x - px;
            var d0y = s0y - py;
            return Math.sqrt(d0x * d0x + d0y * d0y);
        }

        var t = ((px - s0x) * sxLen + (py - s0y) * syLen) / squareLength;
        t = t > 1 ? 1 : (t < 0 ? 0 : t);
        var rx = s0x + t * sxLen;
        var ry = s0y + t * syLen;
        var dx = px - rx;
        var dy = py - ry;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function expire(): Void {
        // force die
        if (life > 0) {
            life = 0;
        }

        // default
        _sprite._alpha = 100;
        var factor = (25 - (life * life)) / 0.25;
        if (factor <= 0) {
            _world.destroy(_self);
        }
        else {
            _sprite._alpha = factor;
            _sprite._xscale = factor;
            _sprite._yscale = factor;
        }
    }

    private function explode(): Void {
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
        var flare: Bullet = flareObject.addComponent(new Bullet());
        flare.life = flareObject.sprite()._totalframes;
        flare._sprite._alpha = 100;
        flare.alpha = 100;
        flare.maxAlpha = 100;
        flare.setSpeed(4);
        flare.setDirection(getDirection());
    }



}