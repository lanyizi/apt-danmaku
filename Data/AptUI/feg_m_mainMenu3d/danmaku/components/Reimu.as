import danmaku.Game;
import danmaku.GameObject;
import danmaku.Options;
import danmaku.components.Alice;
import danmaku.components.Character;
import danmaku.components.Bullet;
import danmaku.components.GuidedBullet;
import danmaku.components.PlayerControl;
import ra3.Lan;

class danmaku.components.Reimu extends Character {
    private var _playerControl: PlayerControl;
    private var _tick: Number;
    private var _slow: Boolean;
    private var _alice: Alice;

    public function Reimu() {
        super(3, 4.5);
        _tick = 0;
        _slow = false;
    }

    private function start(): Void {
        _playerControl = _self.getComponent(PlayerControl);
    }

    private function update(): Void {
        _slow = _playerControl.slowMode > 0;
        _self.sprite().hitBox._visible = _slow;
        if (!Game.instance().fighting) {
            return;
        }
        if (!_alice || !_alice.gameObject()) {
            _alice = _world.findComponents(Alice)[0];
        }
        if ((++_tick) % 4 === 0) {
            fire();
        }
    }

    private function fire(): Void {
        var p = _self.getPosition();
        if (_slow) {
            p.x -= 24;
            for (var i = 0; i < 2; ++i) {
                var bulletObject: GameObject = _world.instantiate("Needle");
                p.x += 16;
                bulletObject.setPosition(p);
                var bullet: Bullet = bulletObject.addComponent(new Bullet());
                bullet.setLength(52);
                bullet.radius = 3;
                bullet.setSpeed(50);
                bullet.life = 40;

                bullet.target = _alice;
                bullet.damage = 15;

                bullet.alpha = 0;
                bullet.maxAlpha = 64;
                bullet.alphaSpeed = 15;
                bullet.explodeFlareId = "BlueFlare";
            }
        }
        else {
            var bulletObject: GameObject = _world.instantiate("Ofuda");
            bulletObject.setPosition(p);
            var bullet: Bullet = bulletObject.addComponent(new GuidedBullet());
            bullet.radius = 9.5;
            bullet.setSpeed(20);
            bullet.life = 70;
            bullet.target = _alice;
            bullet.damage = 2;
            bullet.alpha = 0;
            bullet.maxAlpha = 64;
            bullet.alphaSpeed = 15;
            bullet.explodeFlareId = "YellowFlare";
        }
    }
}