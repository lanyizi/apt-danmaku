import danmaku.GameObject;
import danmaku.components.Character;
import danmaku.components.Flare;

class danmaku.components.Bullet extends Flare {
    private var _length: Number;    // Positive. if 0: circle; not 0: bar
    private var _ex: Number;        // Basically, _direction * length
    private var _ey: Number;        //      if not 0: bullet is a bar
    public var radius: Number;
    public var target: Character;
    public var damage: Number;

    public function Bullet() {
        super();
        _length = 0;
        _ex = 0;
        _ey = 0;
        radius = 0;
        damage = 1;
    }

    public function setDirection(d: Object) {
        super.setDirection(d);
        _ex = _dx * _length;
        _ey = _dy * _length;
    }

    public function getLength(): Number { return _length; }
    public function setLength(l: Number) {
        _length = l;
        _ex = _dx * _length;
        _ey = _dy * _length;
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
}