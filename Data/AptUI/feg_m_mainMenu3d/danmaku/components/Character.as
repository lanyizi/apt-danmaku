import danmaku.Component;
import danmaku.GameObject;

class danmaku.components.Character extends Component {
    private var _maxHitpont: Number;
    public var hitpoint: Number;
    public var radius: Number;

    public function Character(maxHitpont: Number, hitRadius: Number) {
        _maxHitpont = maxHitpont;
        hitpoint = maxHitpont;
        radius = hitRadius;
    }

    public function onShot(damage: Number): Boolean {
        hitpoint -= damage;
        return true;
    }
}