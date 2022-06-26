import danmaku.Game;
import danmaku.GameObject;
import danmaku.components.Alice;
import danmaku.components.Bullet;
import danmaku.components.DynamicBullet;
import danmaku.components.Laser;
import danmaku.components.LaserWarning;
import danmaku.utilities.Bind;

class danmaku.components.AliceStage3 extends Alice {
    private var _bulletType: Number;
    private var _t: Number;
    private var _positionTime: Number;
    private var _displacement: Number;
    private var _spawners: Array;
    private var _lastFire: Number;

    public function AliceStage3() {
        super(400, 10);
        _bulletType = 0;
        _t = 0;
        _positionTime = 0;
        _displacement = 170;
        _spawners = [];
        _lastFire = 0;
    }

    private function start(): Void {
        super.start();
    }

    private function aliceUpdate(): Void {
        ++_t;
        setPosition();
        if (_reimu && _reimu.gameObject()) {
            ++_bulletType;
            var fire = true;
            var numberOfLasers: Number = 16;
            switch (_difficulty) {
                case Game.EASY:
                    fire = (_bulletType % 3) !== 0;
                    numberOfLasers = 4;
                    break;
                case Game.NORMAL:
                    fire = (_bulletType % 4) !== 0;
                    numberOfLasers = 8;
                    break;
                case Game.HARD:
                    numberOfLasers = 12;
                    break;
            }
            var current = _t - _lastFire;
            if (current > 80) {
                _lastFire = _t;
                current = 0;
            }
            if (current < numberOfLasers) {
                fireLaser();
            }
        }
    }
    
    private function fireLaser(): Void {
        var positions: Array = [
            [0, 0],
            [-80, -50],
            [+80, -50],
            [+50, +10],
            [-50, +10]
        ];
        var angles: Array = [ 0, +30, -30, +15, -15, +70, -70 ];
        var i: Number = _t;
        var warningObject: GameObject = _world.instantiate("BlueLaser");
        var position: Object = _self.getPosition();
        var offset: Array = positions[i % positions.length];
        position.x += offset[0];
        position.y += offset[1];
        warningObject.setPosition(position);
        var laserWarning: LaserWarning = warningObject.addComponent(new LaserWarning());
        laserWarning.xScale = 0.25;
        var angle: Number = (angles[i % angles.length] + 90) / 180 * Math.PI;
        var direction: Object = { x: Math.cos(angle), y: Math.sin(angle) };
        laserWarning.setDirection(direction);
        laserWarning.life = 15;
        laserWarning.laserId = "BlueLaser";
        laserWarning.owner = this;
        laserWarning.onLaserCreated = Bind.oneArg(this, function(laser: Laser): Void {
            createSpawner(position, direction, i % 2 == 0);
            laser.xScale = 1;
            laser.yScale = 1;
            laser.setLength(1000);
            laser.target = _reimu;
        });
    }

    private function createSpawner(position: Object, direction: Object, upward: Boolean): Bullet {
        var spawnerObject: GameObject = _world.instantiate("BlueBullet");
        spawnerObject.setPosition(position);
        var spawner: DynamicBullet = spawnerObject.addComponent(new DynamicBullet());
        spawner.setSpeed(0);
        spawner.owner = this;
        spawner.xScale = 2;
        spawner.yScale = 2;
        spawner.alpha = 0;
        spawner.alphaSpeed = 10;
        spawner.maxAlpha = 70;
        spawner.fnT = Bind.oneArg(this, function(t) {
            if (t % 3 !== 2) {
                return;
            }
            t = t / 3;
            if (t > 6) {
                return;
            }
            var bulletObject: GameObject;
            var bullet: Bullet;
            if (upward) {
                bulletObject = _world.instantiate("RedBullet");
                var dynamicBullet: DynamicBullet = bulletObject.addComponent(new DynamicBullet());
                direction.y = -1;
                direction.x = Math.sin(t);
                dynamicBullet.setDirection(direction);
                dynamicBullet.setSpeed(10);
                dynamicBullet.fnT = function() {
                    var direction = dynamicBullet.getDirection();
                    if (direction.y < 1) {
                        direction.y += 0.1;
                        dynamicBullet.setDirection(direction);
                    }
                    dynamicBullet.setSpeed(Math.abs(direction.y) * 10);
                };
                bullet = dynamicBullet;
            }
            else {
                bulletObject = _world.instantiate("BlueBullet");
                bullet = bulletObject.addComponent(new Bullet());
                bullet.setSpeed(t * 6);
                bullet.setDirection(direction)
            }
            bulletObject.setPosition(position);
            bullet.life = 90;
            bullet.radius = 9;
            bullet.owner = this;
            bullet.target = _reimu;
            bullet.explodeFlareId = "YellowFlare";
            bullet.alpha = 32;
            bullet.alphaSpeed = 10;
        });
        return spawner;
    }

    private function setPosition(): Void {
        var t = _t;
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
