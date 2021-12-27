import danmaku.Game;
import danmaku.components.Character;
import danmaku.components.Reimu;

class danmaku.components.Alice extends Character {
    private var _difficulty: Number;
    private var _initialPosition: Object;
    private var _healthBar: MovieClip;
    private var _reimu: Reimu;
    private var _transitionTime: Number;
    private var _nextLevel: Alice;
    public var getNextLevel: Function;

    public function Alice(maxHitpont: Number, hitRadius: Number) {
        super(maxHitpont, hitRadius);
        _difficulty = Game.instance().difficulty;
    }

    private function start(): Void {
        _initialPosition = { x: _world.width() / 2, y: _world.height() / 4 };
        _healthBar = _self.sprite().healthBar;
        _reimu = _world.findComponents(Reimu)[0];
        _transitionTime = 0;

        _self.setPosition(_initialPosition);
    }

    private function update(): Void {
        if (!Game.instance().fighting) {
            _healthBar.showHealth(0);
            return;
        }
        if (hitpoint > 0) {
            aliceUpdate();
            // 假如生命值大于 0，就显示血条
            _healthBar.showHealth(hitpoint / _maxHitpont);
        }
        else {
            // 否则就开始切换到下一个阶段
            toNextStage();
        }
    }

    // 爱丽丝生命值大于 0 时的行为，由派生类重写
    private function aliceUpdate(): Void { }

    // 开始切换到下一个阶段
    private function toNextStage(): Void {
        ++_transitionTime;
        _healthBar.showHealth(Math.max(0, (_transitionTime - 15) / 15));

        var p = _self.getPosition();
        var px = p.x;
        var py = p.y;
        var initialX = _initialPosition.x;
        var initialY = _initialPosition.y;
        var nextX = (initialX + px) / 2;
        var nextY = (initialY + py) / 2;
        // 让爱丽丝回到原位
        if (_transitionTime < 15) {
            _self.setPosition({ x: nextX, y: nextY });
            return;
        }
        else if (_transitionTime === 15) {
            _self.setPosition({ x: initialX, y: initialY });
        }
        // 检查是否还有还有下一阶段
        if (!_nextLevel && getNextLevel) {
            _nextLevel = getNextLevel();
        }
        if (!_nextLevel) {
            // 假如没有的话，就宣告玩家胜利
            Game.instance().setPlayerVictorious();
            _self.removeComponent(this);
            return;
        }
        // 切换到下一阶段
        if (_transitionTime === 30) {
            var self = _self;
            self.removeComponent(this);
            self.addComponent(_nextLevel);
            _nextLevel.getNextLevel = getNextLevel;
        }
    }
}
