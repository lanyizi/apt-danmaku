import danmaku.World;

// 用于调试
class danmaku.utilities.Diagnostics {
    private var _fps: Number;
    private var _previousT: Number;     // 上一次统计 FPS 的时间
    private var _fpsCounter: Number;    // 距离上次记录时间之后至今的帧数
    private var _logs: Array;           // 用于保存日志
    private var _logField: TextField;   // 用于显示日志
    public var logLimit: Number;        // 日志长度限制

    public function Diagnostics(logField: TextField) {
        _fps = NaN;
        _previousT = 0;
        _fpsCounter = 0;
        _logs = [];
        _logField = logField;
        logLimit = 6000;
    }

    public function updateFps(): Number {
        ++_fpsCounter;
        if (_fpsCounter === 15) {
            var t = getTimer();
            _fps = 15000 / (t - _previousT);
            _previousT = t;
            _fpsCounter = 0;
            return _fps;
        }
        return _fps;
    }

    public function getDescription(world: World): String {
        var desc = (world.statistics + "\n");
        var roundedFps = Math.round(_fps * 10) / 10;
        desc += ("FPS: " + roundedFps + "\n");
        var mc: MovieClip = world.movieClip();
        desc += ("Mouse: " + mc._xmouse + ", " + mc._ymouse + "\n");
        return desc;
    }

    // 用来在屏幕上打 log 的临时函数（
    public function log(s: String): Void {
        // 检测同样的消息是不是近期出现过
        for (var i = 1; i < 6; ++i) {
            var t = _logs.length - i;
            if (t < 0) {
                break;
            }
            // 假如近期已经出现过同样的消息
            if (_logs[t].text === s) {
                // 就把它们“折叠”在一起
                ++_logs[t].count;
                s = null;
            }
        }
        // 假如不是重复的，那就保存为一条新的消息
        if (s) {
            _logs.push({ text: s, count: 1 });
        }
        // 生成日志文本
        var result = "";
        for (var i = 0; i < _logs.length; ++i) {
            result += _logs[i].text;
            // 对于重复的消息，显示重复次数
            if (_logs[i].count > 1) {
                result += " (";
                result += _logs[i].count;
                result += ")";
            }
            result += "; ";
        }
        // 假如日志太长了，那么截断保存的消息，这样下一次就不会太长了（
        if (result.length > logLimit) {
            _logs = _logs.slice(Math.floor(_logs.length / 2));
        }
        _logField.text = result;
    }
}