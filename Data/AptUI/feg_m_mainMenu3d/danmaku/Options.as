import danmaku.Game;

class danmaku.Options {
    private static var _instance: Options;
    public var useKeyboardInput: Boolean;
    public var keyUp: Number;
    public var keyLeft: Number;
    public var keyDown: Number;
    public var keyRight: Number;
    public var keySlow: Number;

    public function Options() {
        useKeyboardInput = false;
        keyUp = "W".charCodeAt(0);
        keyLeft = "A".charCodeAt(0);
        keyDown = "S".charCodeAt(0);
        keyRight = "D".charCodeAt(0);
        keySlow = Key.SHIFT;
    }

    public static function instance(): Options {
        if (!_instance) {
            _instance = new Options();
            Game.retrieveRawData(_instance, "options");
        }
        return _instance;
    }
}