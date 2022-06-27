import danmaku.Game;
import danmaku.GameObject;
import danmaku.components.Alice;
import danmaku.components.Bullet;

class danmaku.components.AliceStage2 extends Alice {
    private var _bulletType: Number;
    private var _t: Number;
    private var _positionTime: Number;
    private var _displacement: Number;
    private var _spawners: Array;

    public function AliceStage2() {
        super(400, 10);
        _bulletType = 0;
        _t = 0;
        _positionTime = 0;
        _displacement = 170;
        _spawners = [];
    }

    private function start(): Void {
        super.start();
        for (var i = 0; i < 2; ++i) {
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
            var fire1 = true;
            var fire2 = true;
            switch (_difficulty) {
                case Game.EASY:
                    fire1 = (_bulletType % 3) === 1;
                    fire2 = (_bulletType % 3) === 2;
                    break;
                case Game.NORMAL:
                    fire1 = fire2 = (_bulletType % 3) !== 0;
                    break;
                case Game.HARD:
                    fire1 = fire2 = (_bulletType % 5) !== 0;
                    break;
            }
            updateSpawner(_spawners[0], 0, fire1);
            updateSpawner(_spawners[1], 1, fire2);
        }
    }

    private function createSpawner(index: Number): Bullet {
        var spawnerObject: GameObject = _world.instantiate("YellowBullet");
        var spawner: Bullet = spawnerObject.addComponent(new Bullet());
        spawner.setSpeed(0);
        spawner.expireSpeed = 0;
        spawner.owner = this;
        spawner.xScale = 2;
        spawner.yScale = 2;
        spawner.alpha = 0;
        spawner.alphaSpeed = 10;
        spawner.maxAlpha = 70;
        return spawner;
    }

    private function updateSpawner(spawner: Bullet, index: Number, fire: Boolean): Void {
        var p = _self.getPosition();
        var radius = 90;
        var spawnerObject: GameObject = spawner.gameObject();
        var angle = (index - _t / 30) * Math.PI;
        var spawnerPosition = {
            x: p.x + Math.cos(angle) * radius,
            y: p.y + Math.sin(angle) * radius
        };
        spawnerObject.setPosition(spawnerPosition);

        if (_t % 2 !== 0 || !fire || spawner.alpha < spawner.maxAlpha) {
            return;
        }

        var type = _bulletType % 24;

        var bulletObject: GameObject = _world.instantiate("YellowBullet");
        bulletObject.setPosition(spawnerPosition);
        var bullet: Bullet = bulletObject.addComponent(new Bullet());
        bullet.life = 90;
        bullet.radius = 9;
        bullet.owner = this;
        bullet.target = _reimu;
        bullet.explodeFlareId = "YellowFlare";
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
        var t = _t++;
        if(t % 150 < 90 && t > 1) {
            return;
        }
        t = _positionTime++;
        var px = Math.cos(t / 8);
        var py = Math.sin(t / 8) * px;
        _self.setPosition({
            x: _initialPosition.x + px * _displacement,
            y: _initialPosition.y + py * _displacement
        });
    }
}
