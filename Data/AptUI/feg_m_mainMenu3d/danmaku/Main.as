import danmaku.Cleanup;
import danmaku.World;
import danmaku.components.Alice;
import danmaku.components.AliceStage1;
import danmaku.components.AliceStage2;
import danmaku.components.PlayerControl;
import danmaku.components.Reimu;
import danmaku.overlays.TextButton;
import danmaku.overlays.Options;
import danmaku.utilities.Bind;
import danmaku.utilities.Diagnostics;
import ra3.Lan;
import ra3.MessageHandler;

class danmaku.Main {
    public static function initialize(movieClip: MovieClip): Void {
        var messageHandler: MessageHandler = new MessageHandler();
        messageHandler.addOnExitScreenHandler(function() {
            delete _global.danmaku;
            delete _global.ra3;
        });

        var diagnostics: Diagnostics = new Diagnostics(movieClip.log);
        // 设置写日志的函数
        log = Bind.oneArg(diagnostics, diagnostics.log);

        var worldMovieClip: MovieClip = movieClip.createEmptyMovieClip("world", 100);
        var overlayMovieClip: MovieClip = movieClip.createEmptyMovieClip("overlay", 200);
        var world: World = new World(worldMovieClip, movieClip._width, movieClip._height);

        worldMovieClip.onEnterFrame = function() {
            world.update();
            diagnostics.updateFps();
            movieClip.statistics.text = diagnostics.getDescription(world);
        };
        messageHandler.addOnExitScreenHandler(function() {
            world.destroyAll();
            worldMovieClip.onEnterFrame = null;
        });

        // 暂停按钮，以及选项菜单等
        world.onAfterNextFrame(function() {
            var sprite = overlayMovieClip.attachMovie("TextButton", "pause", 10);
            var pause: TextButton = new TextButton(sprite);
            pause.sprite()._x = 1200;
            pause.sprite()._y = 10;
            pause.setWidth(60);
            pause.setText("\u6682\u505C");
            pause.onClick = function() {
                world.paused = true;
                var menu = overlayMovieClip.attachMovie("Options", "menu", 20);
                var options: Options = new Options(menu, function() {
                    world.paused = false;
                });
            };
        });

        world.onAfterNextFrame(function() {
            var aliceObject = world.instantiate("Alice");
            var levels: Array = [new AliceStage2(), new AliceStage2(), new AliceStage2()];
            var alice1: Alice = aliceObject.addComponent(new AliceStage1());
            alice1.getNextLevel = function() { return levels.shift(); };

            var reimuObject = world.instantiate("Reimu");
            reimuObject.addComponent(new PlayerControl(movieClip.mouseClickChecker));
            reimuObject.addComponent(new Reimu());
        });
    }

    public static function log(message: String): Void {}
}