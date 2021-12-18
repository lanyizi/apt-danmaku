// 管理各种自定义的“系统消息处理函数”
// 它还负责在 Apt 切换的时候自动移除所有的系统消息处理函数
// 因此，写代码的时候，就不用费心去手动释放它们了（（
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

    // 添加一个“系统消息处理函数”
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

    // 添加一个在切换 Apt 的时候执行的函数
    public function addOnExitScreenHandler(f: Function) {
        _onExitScreen.push(f);
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

    private static function bind0(o, f) {
        return function() { return f.call(o); };
    }

    private static function bind1(o, f) {
        return function(x) { return f.call(o, x); };
    }
}