import danmaku.Game;
import danmaku.GameObject;
import danmaku.components.Alice;
import danmaku.components.AliceStage2;
import danmaku.components.Bullet;

class danmaku.components.AliceStage1 extends Alice {
    private var _bulletType: Number;
    private var _t: Number;
    private var _positionTime: Number;
    private var _displacement: Number;
    private var _spawners: Array;

    public function AliceStage1() {
        super(250, 10);
        _bulletType = 0;
        _t = 0;
        _positionTime = 15;
        _displacement = 170;
        _spawners = [];
    }

    private function start(): Void {
        super.start();
        for (var i = 0; i < 3; ++i) {
            var spawner = createSpawner(i);
            updateSpawner(spawner, i, false);
            _spawners.push(spawner);
        }
    }

    private function aliceUpdate(): Void {
        ++_t;
        setPosition();
        if (_reimu && _reimu.gameObject()) {
            ++_bulletType;
            var fire = true;
            switch (_difficulty) {
                case Game.EASY:
                    fire = (_bulletType % 3) !== 0;
                    break;
                case Game.NORMAL:
                    fire = (_bulletType % 4) !== 0;
                    break;
            }
            updateSpawner(_spawners[0], 0, fire);
            updateSpawner(_spawners[1], 1, fire);
            updateSpawner(_spawners[2], 2, fire);
        }
    }

    private function createSpawner(index: Number): Bullet {
        var spawnerObject: GameObject = _world.instantiate("BlueBullet");
        var spawner: Bullet = spawnerObject.addComponent(new Bullet());
        spawner.setSpeed(0);
        spawner.expireSpeed = 0;
        spawner.owner = this;
        spawner.scale = 2;
        spawner.alpha = 0;
        spawner.alphaSpeed = 10;
        spawner.maxAlpha = 70;
        return spawner;
    }

    private function updateSpawner(spawner: Bullet, index: Number, fire: Boolean): Void {
        var p = _self.getPosition();
        var radius = 90;
        var spawnerObject: GameObject = spawner.gameObject();
        var angle = (index * 2 / 3 + _t / 30) * Math.PI;
        var spawnerPosition = {
            x: p.x + Math.cos(angle) * radius,
            y: p.y + Math.sin(angle) * radius
        };
        spawnerObject.setPosition(spawnerPosition);

        if (_t % 2 !== 0 || !fire || spawner.alpha < spawner.maxAlpha) {
            return;
        }

        var type = _bulletType % 24;

        var bulletObject: GameObject = _world.instantiate("BlueBullet");
        bulletObject.setPosition(spawnerPosition);
        var bullet: Bullet = bulletObject.addComponent(new Bullet());
        bullet.life = 90;
        bullet.radius = 9;
        bullet.owner = this;
        bullet.target = _reimu;
        bullet.explodeFlareId = "BlueFlare";
        bullet.setDirection(bulletObject.direction(_reimu.gameObject()));
        bullet.alpha = 32;
        bullet.alphaSpeed = 10;
        var bulletAngle = (type - 6) / 12 * Math.PI;
        bullet.setDirection({
            x: Math.cos(bulletAngle),
            y: Math.sin(bulletAngle)
        });
        bullet.setSpeed(10);
    }

    private function setPosition(): Void {
        if(_t % 180 > 60) {
            return;
        }
        var t = _positionTime++;
        var px = Math.cos(Math.PI * t / 30);
        var py = Math.sin(Math.PI * t / 30) * px;
        _self.setPosition({
            x: _initialPosition.x + px * _displacement,
            y: _initialPosition.y + py * _displacement
        });
    }
}
