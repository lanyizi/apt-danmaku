class ra3.GameSound {
    public static function play(soundId: String, repeat: Number): Void {
        _global.PlayShellMusic("");
        if (_global.SOUND.LAST_VO_PLAYED) {
            danmaku.Main.log("Stopping sound " + _global.SOUND.LAST_VO_PLAYED);
            _global.stopSound(_global.SOUND.LAST_VO_PLAYED);
        }
        // 好像是不能在同一帧停止播放并重新播放相同的音乐
        // 因此使用 setInterval 来实现“延迟调用”
        var nextId = setInterval(function() {
            clearInterval(nextId);

            danmaku.Main.log("Playing sound " + soundId);
            _global.SOUND.LAST_VO_PLAYED = soundId;
            _global.playSound(_global.SOUND.LAST_VO_PLAYED);
            if (isNaN(repeat)) {
                return;
            }
        }, 1);
        if (repeat) {
            var repeatId = setInterval(function() {
                clearInterval(repeatId);
                if (_global.SOUND.LAST_VO_PLAYED === soundId) {
                    danmaku.Main.log("Repeating sound " + soundId);
                    GameSound.play(soundId, repeat);
                }
            }, repeat * 1000);
        }
    }

    public static function playEva(soundId: String): Void {
        _global.playSound(soundId);
    }
}