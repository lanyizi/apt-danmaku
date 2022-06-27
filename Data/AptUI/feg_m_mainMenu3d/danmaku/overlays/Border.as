import danmaku.components.PlayerControl;
// 显示地图边框
class danmaku.overlays.Border {
    private var _border: MovieClip;

    public function Border(scene: MovieClip, playerControl: PlayerControl) {
        var border: MovieClip = scene.attachMovie("Border", "border", 100);
        /*
        红警3 Apt 的遮罩系统十分辣鸡，所以下面的这些代码没有用。
        遮罩只能是在 Flash 里写死的形状，不能使用任何元素，
        更不能像下面的代码那样动态创建的元素作为遮罩

        var mask: MovieClip = border.mask;
        var borderThickness: Number = 4;
        var borderWidth: Number = playerControl.rightEdge - playerControl.leftEdge;
        var borderHeight: Number = playerControl.bottomEdge - playerControl.topEdge;
        var maskTop: MovieClip = mask.attachMovie("BorderMaskElement", "maskTop", 100);
        var maskBottom: MovieClip = mask.attachMovie("BorderMaskElement", "maskBottom", 101);
        var maskLeft: MovieClip = mask.attachMovie("BorderMaskElement", "maskLeft", 102);
        var maskRight: MovieClip = mask.attachMovie("BorderMaskElement", "maskRight", 103);

        maskTop._x = maskBottom._x = playerControl.leftEdge - borderThickness;
        maskTop._y = playerControl.topEdge - borderThickness;
        maskBottom._y = playerControl.bottomEdge;
        maskTop._xscale = maskBottom._xscale = 100 * (borderWidth + borderThickness * 2);
        maskTop._yscale = maskBottom._yscale = 100 * borderThickness;

        maskLeft._y = maskRight._y = playerControl.topEdge - borderThickness;
        maskLeft._x = playerControl.leftEdge - borderThickness;
        maskRight._x = playerControl.rightEdge;
        maskLeft._xscale = maskRight._xscale = 100 * borderThickness;
        maskLeft._yscale = maskRight._yscale = 100 * (borderHeight + borderThickness * 2);
        */

        border.onEnterFrame = function() {
            var movable: MovieClip = border.borderColor;
            movable._x = Math.max(playerControl.leftEdge, Math.min(border._xmouse, playerControl.rightEdge));
            movable._y = Math.max(playerControl.topEdge, Math.min(border._ymouse, playerControl.bottomEdge));
        };
        _border = border;
    }

}