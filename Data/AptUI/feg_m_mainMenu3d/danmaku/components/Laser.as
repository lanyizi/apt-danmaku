import danmaku.components.Character;
import danmaku.components.Bullet;
import danmaku.components.Flare;
import danmaku.GameObject;

class danmaku.components.Laser extends Bullet {

    public function Laser() {
        super();
        // 激光不会移动
        setSpeed(0);
    }

    // 默认情况下弹幕在击中之后会爆炸，爆炸之后会消失
    // 然而激光在命中之后并不会消失
    // 所以对于激光提供一个不会导致消失的的“爆炸”
    public function explode(): Void { }
}
