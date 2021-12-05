class danmaku.Game {
    public static var EASY: Number = 0;
    public static var NORMAL: Number = 1;
    public static var HARD: Number = 2;
    public static var BRUTAL: Number = 3;

    private static var _instance: Game;
    public var difficulty: Number;
    public var fighting: Boolean;
    public var chatProgress: String;

    public function Game() {
        difficulty = BRUTAL;
        fighting = false;
    }

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