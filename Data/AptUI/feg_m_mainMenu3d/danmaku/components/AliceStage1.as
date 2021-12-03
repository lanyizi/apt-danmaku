import danmaku.GameObject;
import danmaku.components.Alice;
import danmaku.components.AliceStage2;
import danmaku.components.Bullet;

class danmaku.components.AliceStage1 extends Alice {
    private var _bulletType: Number;
    private var _t: Number;
    private var _positionTime: Number;
    private var _scale: Number;
    private var _transitionTime: Number;

    public function AliceStage1() {
        super(200, 10);
        _bulletType = 0;
        _t = 0;
        _positionTime = 15;
        _scale = 170;
        _transitionTime = 0;
    }

    private function update(): Void {
        if (hitpoint > 0) {
            setPosition();
            if (_reimu && _reimu.gameObject()) {
                fire();
            }
            _healthBar.showHealth(hitpoint / _maxHitpont);
        }
        else {
            toNextStage();
        }
    }

    private function fire(): GameObject {
        if (hitpoint <= 0) {
            return;
        }
        var type = _bulletType++ % 24;

        var bulletObject: GameObject = _world.instantiate("BlueBullet");
        bulletObject.setPosition(_self.getPosition());
        var bullet: Bullet = bulletObject.addComponent(new Bullet());
        bullet.life = 80;
        bullet.radius = 9;
        bullet.owner = this;
        bullet.target = _reimu;
        bullet.explodeFlareId = "BlueFlare";
        bullet.setDirection(bulletObject.direction(_reimu.gameObject()));
        bullet.alpha = 32;
        bullet.alphaSpeed = 10;
        var angle = (type - 6) / 12 * Math.PI;
        bullet.setDirection({ x: Math.cos(angle), y: Math.sin(angle) });
        bullet.setSpeed(15);

        return bulletObject;
    }

    private function setPosition(): Void {
        var t = _t++;
        var scale = 170;
        if(t % 150 > 60) {
            return;
        }
        t = _positionTime++;
        var px = Math.cos(Math.PI * t / 30);
        var py = Math.sin(Math.PI * t / 30) * px;
        _self.setPosition({
            x: _initialPosition.x + px * scale,
            y: _initialPosition.y + py * scale
        });
    }
}
