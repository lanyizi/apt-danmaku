import danmaku.Cleanup;
import danmaku.World;
import danmaku.components.Alice;
import danmaku.components.AliceStage1;
import danmaku.components.AliceStage2;
import danmaku.components.PlayerControl;
import danmaku.components.Reimu;
import ra3.Lan;
import ra3.MessageHandler;

class danmaku.Main {
    public static function initialize(movieClip: MovieClip): Void {
        var messageHandler: MessageHandler = new MessageHandler();
        messageHandler.addOnExitScreenHandler(function() {
            delete _global.danmaku;
            delete _global.ra3;
        });

        var worldMovieClip = movieClip.createEmptyMovieClip("world", 100);
        var overlayMovieClip = movieClip.createEmptyMovieClip("overlay", 200);
        var world: World = new World(worldMovieClip, movieClip._width, movieClip._height);

        var fps = NaN;
        var previousT = getTimer();
        var fpsCounter = 0;
        worldMovieClip.onEnterFrame = function() {
            world.update();
            if (++fpsCounter === 15) {
                var t = getTimer();
                fps = 15000 / (t - previousT);
                previousT = t;
                fpsCounter = 0;
                return;
            }
            movieClip.statistics.text = world.statistics + "\n FPS: " + fps;
        };
        messageHandler.addOnExitScreenHandler(function() {
            world.destroyAll();
            worldMovieClip.onEnterFrame = null;
        });

        var aliceObject = world.instantiate("Alice");
        var levels: Array = [new AliceStage2(), new AliceStage2(), new AliceStage2()];
        var alice1: Alice = aliceObject.addComponent(new AliceStage1());
        alice1.getNextLevel = function() { return levels.shift(); };

        var reimuObject = world.instantiate("Reimu");
        reimuObject.addComponent(new PlayerControl(movieClip.mouseClickChecker));
        reimuObject.addComponent(new Reimu());
    }
}