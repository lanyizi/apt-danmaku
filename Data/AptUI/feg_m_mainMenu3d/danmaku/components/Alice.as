import danmaku.Game;
import danmaku.components.Character;
import danmaku.components.Reimu;

class danmaku.components.Alice extends Character {
    private var _initialPosition: Object;
    private var _healthBar: MovieClip;
    private var _reimu: Reimu;
    private var _transitionTime: Number;
    private var _nextLevel: Alice;
    public var getNextLevel: Function;

    public function Alice(maxHitpont: Number, hitRadius: Number) {
        super(maxHitpont, hitRadius);
    }

    private function start(): Void {
        _initialPosition = { x: _world.width() / 2, y: _world.height() / 4 };
        _healthBar = _self.sprite().healthBar;
        _reimu = _world.findComponents(Reimu)[0];
        _transitionTime = 0;
    }

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
        if (_transitionTime < 15) {
            _self.setPosition({ x: nextX, y: nextY });
            return;
        }
        else if (_transitionTime === 15) {
            _self.setPosition({ x: initialX, y: initialY });
        }
        if (!_nextLevel && getNextLevel) {
            _nextLevel = getNextLevel();
        }
        if (!_nextLevel) {
            Game.instance().setPlayerVictorious();
            _self.removeComponent(this);
            return;
        }
        if (_transitionTime === 30) {
            var self = _self;
            self.removeComponent(this);
            self.addComponent(_nextLevel);
            _nextLevel.getNextLevel = getNextLevel;
        }
    }
}
