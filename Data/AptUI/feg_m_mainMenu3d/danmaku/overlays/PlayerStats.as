import danmaku.components.Reimu;
import danmaku.Game;
import danmaku.World;
import danmaku.utilities.Bind;

class danmaku.overlays.PlayerStats {
    private var _sprite: MovieClip;
    private var _hp: TextField;
    private var _reimu: Reimu;

    public function PlayerStats(sprite: MovieClip, world: World) {
        _sprite = sprite;
        _hp = _sprite.hp;
        _sprite._visible = false;
        world.addOnFrameListener("playerStats", Bind.noArg(this, function() {
            _sprite._visible = Game.instance().fighting;
            if (!_sprite._visible) {
                return;
            }
            if (!_reimu || !_reimu.gameObject().sprite()) {
                _reimu = world.findComponents(Reimu)[0];
            }
            else {
                _hp.text = String(_reimu.hitpoint);
            }
        }));
    }
}