import danmaku.components.Character;
import danmaku.components.Bullet;
import danmaku.components.Flare;
import danmaku.GameObject;

// 先显示预警，之后产生实际的激光
class danmaku.components.LaserWarning extends Flare {
    private var _laserCreated: Boolean;
    public var laserId: String;
    public var onLaserCreated: Function; // 自定义的处理函数

    public function LaserWarning() {
        super();
        _laserCreated = false;
        laserId = null;
        onLaserCreated = null;
        // 激光预警不会移动
        setSpeed(0);
    }

    public function expire(): Void {
        if (!_exploded) {
            // 假如是爆炸了，对于 Flare 来说一般只有可能是因为 owner 也被击败了
            // 那种情况下就不要产生激光了
            // 但假如没有爆炸，那在 Flare 消失的时候，
            // 就该产生激光了
            createLaser();
        }
        super.expire();
    }

    private function createLaser(): Void {
        if (_laserCreated) {
            return;
        }
        _laserCreated = true;
        // 创建激光
        var laserObject: GameObject = _world.instantiate(laserId);
        var laser: Bullet = laserObject.addComponent(new Bullet());
        // 复制激光预警的方向
        laser.setDirection(getDirection());
        // 以及坐标
        laserObject.setPosition(_self.getPosition());
        // 以及其他的一些参数
        laser.owner = owner;
        laser.xScale = xScale;
        laser.yScale = yScale;
        // 激光不会移动
        if (onLaserCreated) {
            // 假如有的话，执行自定义的初始化
            onLaserCreated(laser);
        }
    }
}
