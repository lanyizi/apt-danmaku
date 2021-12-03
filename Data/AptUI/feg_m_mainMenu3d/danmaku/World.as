import danmaku.GameObject;

class danmaku.World {
    public static var test: MovieClip;

    private var _movieClip: MovieClip;
    private var _width: Number;
    private var _height: Number;
    private var _updaters: Object;
    private var _lateUpdaters: Object;
    private var _gameObjects: Object;
    private var _occupiedDepths: Array;
    private var _freeDepths: Array;
    private var _nextId: Number;
    public var paused: Boolean;
    public var statistics: String;

    public function World(movieClip: MovieClip, width: Number, height: Number) {
        _movieClip = movieClip;
        _width = width;
        _height = height;
        _updaters = {};
        _lateUpdaters = {};
        _gameObjects = {};
        _occupiedDepths = [];
        _freeDepths = [];
        _nextId = 1;
        paused = false;
        statistics = "";
    }

    public function movieClip(): MovieClip { return _movieClip; }
    public function width(): Number { return _width; }
    public function height(): Number { return _height; }

    private var _logs: Array = [];
    public function log(s: String): Void {
        if (s.charAt(0) === '$') {
            for (var i = 0; !!_movieClip._parent["localize" + i]; ++i) {
                if (_movieClip._parent["localize" + i].text.length == 0) {
                    _movieClip._parent["localize" + i].text = s;
                    return;
                }
            }
            for (var i = 0; !!_movieClip._parent["localize" + i]; ++i) {
                _movieClip._parent["localize" + i].text = "";
            }
            _movieClip._parent.localize0.text = s;
            return;
        }
        for (var i = 1; i < 6; ++i) {
            var t: Number = _logs.length - i;
            if (t < 0) {
                break;
            }
            if (_logs[t].text === s) {
                ++_logs[t].count;
                s = null;
            }
        }
        if (s) {
            _logs.push({ text: s, count: 1 });
        }
        var r: String = "";
        for (var i = 0; i < _logs.length; ++i) {
            r += _logs[i].text;
            if (_logs[i].count > 1) {
                r += " (";
                r += _logs[i].count;
                r += ")";
            }
            r += "; ";
        }
        if (r.length > 6000) {
            _logs = _logs.slice(Math.floor(_logs.length / 2));
        }
        _movieClip._parent.log.text = r;
    }

    public function update(): Void {
        if (paused) {
            return;
        }
        var objectCount = 0;
        for (var k in _gameObjects) {
            _gameObjects[k].updateInitialPosition();
            ++objectCount;
        }

        var updaters = [];
        var lateUpdaters = [];
        for (var k in _updaters) {
            updaters.push(_updaters[k]);
        }
        for (var k in _lateUpdaters) {
            lateUpdaters.push(_lateUpdaters[k]);
        }

        var length = updaters.length;
        var lateUpdatersLength = lateUpdaters.length;
        for (var i = 0; i < length; ++i) {
            updaters[i]();
        }
        for (var i = 0; i < lateUpdatersLength; ++i) {
            lateUpdaters[i]();
        }
        statistics = "Objects: " + objectCount + ";\n";
        statistics += "Updaters: " + length + "; ";
        statistics += "Late updaters: " + lateUpdatersLength + ";\n";
        statistics += "Occupied depths: " + _occupiedDepths.length + "; ";
        statistics += "Free depths: " + _freeDepths.length + ";\n";
        statistics += "Next id: " + _nextId + ";"
    }

    public function instantiate(movieClipId: String, depth: Number): GameObject {
        if (isNaN(depth)) {
            if (_freeDepths.length > 0) {
                depth = Number(_freeDepths.shift());
            }
            else {
                depth = _occupiedDepths.length;
            }
        }
        if (_occupiedDepths[depth]) {
            destroy(_occupiedDepths[depth]);
        }

        var objectId = "i__" + (_nextId++);
        var sprite = _movieClip.attachMovie(movieClipId, objectId, depth);
        var object = new GameObject(this, objectId, sprite);
        _gameObjects[object.id()] = object;
        _occupiedDepths[depth] = object;
        return object;
    }

    public function notifyDepthSwap(lhs: GameObject, rhs: GameObject) {
        _occupiedDepths[lhs.depth()] = lhs;
        _occupiedDepths[rhs.depth()] = rhs;
    }

    public function destroy(gameObject: GameObject): Void {
        gameObject.removeAllComponents();
        delete _gameObjects[gameObject.id()];
        var sprite: MovieClip = gameObject.sprite();
        var depth = gameObject.depth();
        if (depth !== undefined) {
            delete _occupiedDepths[depth];
            _freeDepths.push(depth);
        }
        sprite.removeMovieClip();
    }

    public function destroyAll() {
        var objects = [];
        for (var k in _gameObjects) {
            objects.push(_gameObjects[k]);
        }
        var length = objects.length;
        for (var i = 0; i < length; ++i) {
            destroy(objects[i]);
        }
        _updaters = [];
    }

    public function findComponents(type: Object): Array {
        var result = [];
        for (var k in _gameObjects) {
            var component = _gameObjects[k].getComponent(type);
            if (component) {
                result.push(component);
            }
        }
        return result;
    }

    public function addOnFrameListener(id: String, f: Function): Void {
        _updaters[id] = f;
    }

    public function removeOnFrameListener(id: String): Void {
        delete _updaters[id];
    }

    public function onNextFrame(f: Function): String {
        var handlerId = "f__" + (_nextId++);
        var self = this;
        addOnFrameListener(handlerId, function() {
            self.removeOnFrameListener(handlerId);
            f();
        });
        return handlerId;
    }

    public function addAfterFrameListener(id: String, f: Function): Void {
        _lateUpdaters[id] = f;
    }

    public function removeAfterFrameListener(id: String): Void {
        delete _lateUpdaters[id];
    }

    public function onAfterNextFrame(f: Function): String {
        var handlerId = "f__" + (_nextId++);
        var self = this;
        addAfterFrameListener(handlerId, function() {
            self.removeAfterFrameListener(handlerId);
            f();
        });
        return handlerId;
    }
}