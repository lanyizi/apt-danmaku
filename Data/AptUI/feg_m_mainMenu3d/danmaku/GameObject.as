import danmaku.Component;
import danmaku.World;

class danmaku.GameObject {
    private var _world: World;
    private var _id: String;
    private var _sprite: MovieClip;
    private var _initialX: Number;
    private var _initialY: Number;
    private var _depth: Number;
    private var _components: Array;
    private var _nextComponentId: Number;

    public function GameObject(world: World, id: String, sprite: MovieClip) {
        _world = world;
        _id = id;
        _sprite = sprite;
        _components = [];
        _nextComponentId = 0;
        _depth = sprite.getDepth();
        updateInitialPosition();
    }

    public function isDestroyed(): Boolean { return !_sprite; }
    public function world(): World { return _world; }
    public function id(): String { return _id; }
    public function sprite(): MovieClip { return _sprite; }
    public function depth(): Number { return _depth; }

    public function getPosition(): Object {        return { x: _sprite._x, y: _sprite._y };
    }
    public function setPosition(v: Object) {
        _sprite._x = v.x;
        _sprite._y = v.y;
    }

    public function updateInitialPosition(): Void {
        _initialX = _sprite._x;
        _initialY = _sprite._y;
    }

    public function previousPosition(): Object {
        return { x: _initialX, y: _initialY };
    }

    public function swapDepth(other: GameObject): Void {
        if (isDestroyed() || other.isDestroyed()) {
            return;
        }
        _sprite.swapDepths(other._sprite);
        _depth = _sprite.getDepth();
        other._depth = other._sprite.getDepth();
        _world.notifyDepthSwap(this, other);
    }

    public function direction(other: GameObject): Object {
        return {            x: other._sprite._x - _sprite._x,            y: other._sprite._y - _sprite._y
        };
    }

    public function distance(other: GameObject): Number {
        var dx = other._sprite._x - _sprite._x;        var dy = other._sprite._y - _sprite._y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    public function addComponent(c: Component) {
        if (isDestroyed()) {
            throw new Error("GameObject already destroyed");
        }
        if (getComponent(c) !== undefined) {
            throw new Error("Component already added");
        }
        ++_nextComponentId;
        _components.push(c);
        var self = this;
        c.onAdded(self, _nextComponentId)
        return c;
    }

    public function getComponent(type: Object) {
        var candidate = undefined;
        var length = _components.length;
        for (var i = 0; i < length; ++i) {
            var component = _components[i];
            if (instanceOf(component, type)) {
                candidate = component;
                if (instanceOf(type, component)) {
                    return component;
                }
            }
        }
        return candidate;
    }

    public function removeComponent(type: Object): Void {
        var candidateIndex = undefined;
        var length = _components.length;
        for (var i = 0; i < length; ++i) {
            var component = _components[i];
            if (instanceOf(component, type)) {
                candidateIndex = i;
                if (instanceOf(type, component)) {
                    break;
                }
            }
        }
        if (candidateIndex !== undefined) {
            _components.splice(candidateIndex, 1)[0].onRemoved();
        }
    }

    public function removeAllComponents(): Void {
        var components = _components;
        _components = [];
        var length = components.length;
        for (var i = 0; i < length; ++i) {
            components[i].onRemoved();
        }
    }

    private static function instanceOf(self, check): Boolean {
        self = typeof self === 'function'            ? self.prototype            : self.__proto__;
        check = typeof check === 'function'            ? check.prototype            : check.__proto__;
        while (self) {
            if (self === check) {
                return true;
            }
            self = self.__proto__;
        }
        return false;
    }
}