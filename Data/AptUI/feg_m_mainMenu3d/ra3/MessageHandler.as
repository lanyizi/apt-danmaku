class ra3.MessageHandler {
    private var _onExitScreen: Array;
    private var _messageHandlers: Array;
    private var _handler: Function;

    public function MessageHandler() {
        _onExitScreen = [];
        _messageHandlers = [];
        _handler = bind1(this, onMessage);
        _global.gSM.setOnExitScreen(bind0(this, onExitScreen));
        _global.gMH.addMessageHandler(_handler);
    }

    public function addMessageHandler(f: Function) {
        _messageHandlers.push(f);
    }

    public function removeMessageHandler(f: Function) {
        var length = _messageHandlers.length;
        for (var i = 0; i < length; ++i) {
            if (_messageHandlers[i] === f) {
                _messageHandlers.splice(i, 1);
                return;
            }
        }
    }

    public function addOnExitScreenHandler(f: Function) {
        _onExitScreen.push(f);
    }

    public static function bind0(o, f) {
        return function() { return f.call(o); };
    }

    public static function bind1(o, f) {
        return function(x) { return f.call(o, x); };
    }

    public static function bind2(o, f) {
        return function(x, y) { return f.call(o, x, y); };
    }

    private function onMessage(message): Boolean {
        var handlers = _messageHandlers.slice(0);
        var length = handlers.length;
        for (var i = 0; i < length; ++i) {
            if (handlers[i](message)) {
                return true;
            }
        }
        return false;
    }

    private function onExitScreen() {
        _global.gMH.removeMessageHandler(_handler);
        while(_onExitScreen.length > 0) {
            var f = _onExitScreen.pop();
            f();
        }
    }
}