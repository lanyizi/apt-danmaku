import danmaku.GameObject;
import danmaku.components.Bullet;

class danmaku.components.GuidedBullet extends Bullet {
    private var _targetGameObject: GameObject;
    private var _energyPeak: Number;
    private var _energyDelta: Number;
    private var _energy: Number;

    public function start(): Void {
        super.start();
        _energyPeak = life * 0.6;
        _energyDelta = 30 / (0.2 * life);
        _energy = 0;

        if (target) {
            _targetGameObject = target.gameObject();
        }
    }

    public function update(): Void {
        if (life <= 0 || _energy < 0) {
            super.update();
            return;
        }
        if (life > _energyPeak) {
            _energy += _energyDelta;
        }
        else {
            _energy -= _energyDelta;
        }
        if (_targetGameObject && !_targetGameObject.isDestroyed()) {
            var newDirection = _self.direction(_targetGameObject);
            var x = newDirection.x;
            var y = newDirection.y;
            var rotation = Math.atan2(y, x) * 180 / Math.PI + 90;
            var diff = rotation - _rotation;
            diff = ((diff % 360) + 360) % 360;
            if (diff > 180) {
                diff -= 360;
            }
            diff = Math.max(-_energy, Math.min(_energy, diff));
            var realNextRotation = (_rotation + diff - 90) * Math.PI / 180;
            setDirection({ x: Math.cos(realNextRotation), y: Math.sin(realNextRotation) });
        }
        super.update();
    }
}