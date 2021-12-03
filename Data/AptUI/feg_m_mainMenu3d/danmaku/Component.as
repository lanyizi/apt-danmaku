import danmaku.GameObject;
import danmaku.World;

class danmaku.Component {
    private var _self: GameObject;
    private var _world: World;
    private var _componentId: String;
    private var _started: Boolean;

    public function onAdded(self: GameObject, id: Number): Void {
        if (_self) {
            throw new Error("Cannot add component to multiple GameObjects")
        }
        _self = self;
        _world = _self.world();
        _componentId = self.id() + "_c" + id;
        _started = false;
        var bind0 = function(o, f) { return function() { f.call(o); }; };

        var hasStart = start !== Component.prototype.start;
        var hasUpdate = update !== Component.prototype.update;
        if (hasStart || hasUpdate) {
            _world.addOnFrameListener(_componentId, bind0(this, function() {
                if (!_self || _self.isDestroyed()) {
                    return;
                }
                if (!_started) {
                    _started = true;
                    start();
                    if (!_self || _self.isDestroyed()) {
                        return;
                    }
                    if (!hasUpdate) {
                        _world.removeOnFrameListener(_componentId);
                    }
                }
                update();
            }));
        }

        if (lateUpdate !== Component.prototype.lateUpdate) {
            _world.addAfterFrameListener(_componentId, bind0(this, function() {
                if (!_self || _self.isDestroyed()) {
                    return;
                }
                lateUpdate();
            }));
        }

        awake();
    }

    public function onRemoved(): Void {
        _self = undefined;
        _world.removeOnFrameListener(_componentId);
        _world.removeAfterFrameListener(_componentId);
        _world = undefined;
        _componentId = undefined;
        _started = false;
    }

    public function gameObject(): GameObject { return _self; }

    public function awake(): Void { }
    public function start(): Void { }
    public function update(): Void { }
    public function lateUpdate(): Void { }
}