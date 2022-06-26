import danmaku.GameObject;
import danmaku.components.Bullet;

class danmaku.components.DynamicBullet extends Bullet {
    private var _t: Number;
    public var fnT: Function;

    public function start(): Void {
        super.start();
        _t = 0;
        fnT(_t);
    }

    public function update(): Void {
        if (life > 0) {
            fnT(++_t);
        }
        super.update();
    }
}