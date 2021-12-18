class danmaku.utilities.Bind {
    public static function noArg(o: Object, f: Function): Function {
        return function() { return f.call(o); };
    }

    public static function oneArg(o: Object, f: Function): Function {
        return function(a) { return f.call(o, a); };
    }
}