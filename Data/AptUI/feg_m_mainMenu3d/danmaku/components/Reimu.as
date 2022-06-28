import danmaku.Game;
import danmaku.GameObject;
import danmaku.Options;
import danmaku.components.Alice;
import danmaku.components.Character;
import danmaku.components.Flare;
import danmaku.components.Bullet;
import danmaku.components.GuidedBullet;
import danmaku.components.PlayerControl;
import ra3.GameSound;

class danmaku.components.Reimu extends Character {
    private var _playerControl: PlayerControl;
    private var _tick: Number;
    private var _slow: Boolean;
    private var _alice: Alice;
    private var _resurrectCounter: Number;

    public function Reimu() {
        super(3, 4.5);
        _tick = 0;
        _slow = false;
        _resurrectCounter = -1;
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
        if (_resurrectCounter > 0) {
            --_resurrectCounter;
            _self.sprite()._alpha = 100 * Math.pow(Math.cos(_resurrectCounter), 2);
        }
        else if ((++_tick) % 4 === 0) {
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
                bullet.setSpeed(60);
                bullet.life = 40;

                bullet.target = _alice;
                bullet.damage = 20;

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

    public function onShot(damage: Number): Boolean {
        if (_resurrectCounter > 0 || hitpoint <= 0) {
            return false;
        }
        hitpoint -= damage;
        // 死亡特效
        for (var i = 0; i < 6; ++i) {
            var flareObject: GameObject = _world.instantiate("YellowFlare");
            flareObject.setPosition(_self.getPosition());
            var flare: Flare = flareObject.addComponent(new Flare());
            var angle = Math.random() * 2 * Math.PI;
            flare.setDirection({ x: Math.cos(angle), y: Math.sin(angle) });
            flare.setSpeed(Math.random() * 20 + 20);
        }
        if (hitpoint > 0) {
            _resurrectCounter = 60;
            GameSound.playEva("UnitUnderAttack");
        }
        else {
            GameSound.playEva("UnitLost");
            _world.onNextFrame(function() {
                Game.instance().setPlayerDefeated();
            });
        }
        return true;
    }
}