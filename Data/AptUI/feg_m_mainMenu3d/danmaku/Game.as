class danmaku.Game {
    private static var _instance: Game;
    public var fighting: Boolean;
    public var chatProgress: String;

    public function setPlayerVictorious(): Void {
        fighting = false;
    }

    public function setPlayerDefeated(): Void {
        fighting = false;
    }

    public static function instance(): Game {
        if (!_instance) {
            _instance = new Game();
            retrieveRawData(_instance, "game");
            _instance.fighting = true;
        }
        return _instance;
    }

    public static function cacheRawData(target, key: String): Void {
        var result: Object = {};
        for (var k in target) {
            var value = target[k];
            switch (typeof value) {
                case "boolean":
                case "number":
                case "string":
                    result[k] = value;
                    break;
            }
        }
        if (!_global.danmakuStore) {
            _global.danmakuStore = {};
        }
        _global.danmakuStore[key] = result;
    }

    public static function retrieveRawData(target, key: String): Void {
        if (!_global.danmakuStore) {
            return;
        }
        var cached: Object = _global.danmakuStore[key];
        if (!cached) {
            return;
        }
        for (var k in cached) {
            target[k] = cached[k];
        }
    }
}